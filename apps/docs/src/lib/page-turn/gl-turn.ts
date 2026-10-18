import { clamp01 } from '@/lib/scroll-progress';
import type { Raster } from './raster';
import { FRAGMENT_SHADER, VERTEX_SHADER } from './shader';
import { SWITCHING, TOP_LAYER, easeInOutCubic, turnState } from './shared';

export interface GlTurnOptions {
  paper: string;
  /** The sheet being turned is dark. */
  dark: boolean;
  /** The page under the sheet is dark. */
  underDark: boolean;
  dir: 1 | -1;
  duration?: number;
  /** Called once the canvas covers the page. */
  onShown?: () => void;
}

const UNIFORMS = [
  'uTex',
  'uBg',
  'uHasBg',
  'uRes',
  'uA',
  'uD',
  'uPaper',
  'uDpr',
  'uSign',
  'uR',
  'uShadow',
  'uEdge',
  'uSpec',
  'uInk',
] as const;

type Uniform = (typeof UNIFORMS)[number];

/** Any CSS color as 0..1 RGB, normalized through a 2D context. */
function toRgb(color: string): [number, number, number] {
  const context = document.createElement('canvas').getContext('2d');
  if (!context) return [1, 1, 1];
  context.fillStyle = color;
  const hex = /^#([0-9a-f]{6})$/i.exec(context.fillStyle)?.[1];
  if (!hex) return [1, 1, 1];
  const value = parseInt(hex, 16);
  return [
    ((value >> 16) & 255) / 255,
    ((value >> 8) & 255) / 255,
    (value & 255) / 255,
  ];
}

function compile(gl: WebGLRenderingContext, type: number, source: string) {
  const shader = gl.createShader(type);
  if (!shader) throw new Error('shader');
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    throw new Error(gl.getShaderInfoLog(shader) ?? 'shader');
  }
  return shader;
}

function texture(
  gl: WebGLRenderingContext,
  unit: number,
  source: TexImageSource
) {
  gl.activeTexture(unit);
  gl.bindTexture(gl.TEXTURE_2D, gl.createTexture());
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, source);
}

/** Compiles the curl program over a full-screen triangle. */
function setup(gl: WebGLRenderingContext, sheet: Raster, under: Raster | null) {
  const program = gl.createProgram();
  if (!program) throw new Error('program');
  gl.attachShader(program, compile(gl, gl.VERTEX_SHADER, VERTEX_SHADER));
  gl.attachShader(program, compile(gl, gl.FRAGMENT_SHADER, FRAGMENT_SHADER));
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw new Error('link');
  gl.useProgram(program);
  gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
  gl.bufferData(
    gl.ARRAY_BUFFER,
    new Float32Array([-1, -1, 3, -1, -1, 3]),
    gl.STATIC_DRAW
  );
  const attribute = gl.getAttribLocation(program, 'a');
  gl.enableVertexAttribArray(attribute);
  gl.vertexAttribPointer(attribute, 2, gl.FLOAT, false, 0, 0);
  texture(gl, gl.TEXTURE1, (under ?? sheet).canvas);
  texture(gl, gl.TEXTURE0, sheet.canvas);
  const uniforms = new Map<Uniform, WebGLUniformLocation | null>();
  for (const name of UNIFORMS)
    uniforms.set(name, gl.getUniformLocation(program, name));
  return (name: Uniform) => uniforms.get(name) ?? null;
}

/**
 * Curls the rasterized sheet off the page (or, with `under`, plays the
 * curl backwards over a still of the old page) and resolves when done.
 */
export function glTurn(
  options: GlTurnOptions,
  sheet: Raster,
  commit: () => void,
  under: Raster | null = null
): Promise<void> {
  const { width: W, height: H, dpr } = sheet;
  const canvas = document.createElement('canvas');
  canvas.width = sheet.canvas.width;
  canvas.height = sheet.canvas.height;
  canvas.setAttribute('aria-hidden', 'true');
  canvas.style.cssText = `position:fixed;left:0;top:0;width:${W}px;height:${H}px;z-index:${TOP_LAYER};pointer-events:none`;
  const gl = canvas.getContext('webgl', {
    alpha: true,
    premultipliedAlpha: true,
    antialias: false,
  });
  if (!gl) throw new Error('no webgl');
  const u = setup(gl, sheet, under);
  const paper = toRgb(options.paper);
  gl.uniform1i(u('uTex'), 0);
  gl.uniform1i(u('uBg'), 1);
  gl.uniform1f(u('uHasBg'), under ? 1 : 0);
  gl.uniform2f(u('uRes'), W, H);
  gl.uniform1f(u('uDpr'), dpr);
  gl.uniform1f(u('uSign'), options.dir);
  gl.uniform3f(u('uPaper'), paper[0], paper[1], paper[2]);
  gl.uniform1f(u('uSpec'), options.dark ? 0.05 : 0.07);
  gl.uniform1f(u('uInk'), options.dark ? 0.1 : 0.075);
  gl.viewport(0, 0, canvas.width, canvas.height);
  const draw = curlFrame(gl, u, options, W, H);
  return play(canvas, gl, draw, options, commit, under !== null);
}

const smooth = (a: number, b: number, x: number) => {
  const t = clamp01((x - a) / (b - a));
  return t * t * (3 - 2 * t);
};

/** Draws the curl at time t (0..1): axis, radius and tilt follow the ease. */
function curlFrame(
  gl: WebGLRenderingContext,
  u: (name: Uniform) => WebGLUniformLocation | null,
  options: GlTurnOptions,
  W: number,
  H: number
) {
  return (t: number) => {
    const e = easeInOutCubic(t);
    const bulge = Math.sin(Math.PI * e);
    const radius = Math.max(22, W * (0.05 + 0.1 * bulge));
    const axis = W + 1 - e * (W * 1.09 + 8);
    const angle = -0.07 * bulge;
    const fade = smooth(0, 0.06, e) * (1 - smooth(0.88, 1, e));
    gl.uniform2f(u('uA'), axis, H / 2);
    gl.uniform2f(u('uD'), Math.cos(angle), Math.sin(angle));
    gl.uniform1f(u('uR'), radius);
    gl.uniform1f(u('uShadow'), (options.underDark ? 0.5 : 0.22) * fade);
    gl.uniform1f(u('uEdge'), (options.dark ? 0.5 : 0.2) * fade);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
  };
}

function play(
  canvas: HTMLCanvasElement,
  gl: WebGLRenderingContext,
  draw: (t: number) => void,
  options: GlTurnOptions,
  commit: () => void,
  reverse: boolean
): Promise<void> {
  const html = document.documentElement;
  const duration = options.duration ?? 1250;
  return new Promise((resolve) => {
    let raf = 0;
    let start = 0;
    let done = false;
    const finish = () => {
      if (done) return;
      done = true;
      cancelAnimationFrame(raf);
      canvas.remove();
      html.removeAttribute(SWITCHING);
      gl.getExtension('WEBGL_lose_context')?.loseContext();
      if (turnState.finish === finish) turnState.finish = null;
      resolve();
    };
    const tick = (now: number) => {
      if (!start) start = now;
      const t = Math.min(1, (now - start) / duration);
      draw(reverse ? 1 - t : t);
      if (t >= 1) finish();
      else raf = requestAnimationFrame(tick);
    };
    draw(reverse ? 1 : 0);
    document.body.append(canvas);
    options.onShown?.();
    html.setAttribute(SWITCHING, '');
    turnState.finish = finish;
    commit();
    raf = requestAnimationFrame(tick);
  });
}

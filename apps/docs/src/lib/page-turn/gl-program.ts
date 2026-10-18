import type { Raster } from './raster';
import { FRAGMENT_SHADER, VERTEX_SHADER } from './shader';

/** WebGL plumbing for the curl: program, textures, uniforms, colors. */

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

export type Uniform = (typeof UNIFORMS)[number];

/** Any CSS color as 0..1 RGB, normalized through a 2D context. */
export function toRgb(color: string): [number, number, number] {
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
export function setup(
  gl: WebGLRenderingContext,
  sheet: Raster,
  under: Raster | null
): (name: Uniform) => WebGLUniformLocation | null {
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

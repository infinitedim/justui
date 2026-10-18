import { clamp01 } from '@/lib/scroll-progress';
import {
  SWITCHING,
  TOP_LAYER,
  easeInOutCubic,
  emptyBox,
  isOffscreen,
  overlayDiv,
  turnState,
  type TurnOptions,
} from './shared';

/**
 * Fallback turn (no WebGL, tainted canvas, fonts not ready): the visible
 * page is cloned into vertical strips chained in 3D, each hinged to the
 * previous one, so the sheet bows while it rotates about its spine. The
 * bend travels from the spine to the free edge, so it reads as paper.
 * Reduced motion gets a 220ms crossfade instead.
 */

/** Clone with large off-screen blocks emptied, so strip copies stay light. */
function snapshot(root: HTMLElement, height: number): HTMLElement | null {
  const copy = root.cloneNode(true);
  if (!(copy instanceof HTMLElement)) return null;
  const walk = (source: Element, target: Element, depth: number) => {
    Array.from(source.children).forEach((el, index) => {
      const clone = target.children[index];
      if (!clone) return;
      const rect = el.getBoundingClientRect();
      if (clone instanceof HTMLElement && isOffscreen(rect, height)) {
        const style = getComputedStyle(el);
        const pinned =
          style.position === 'fixed' || style.position === 'sticky';
        if (!pinned && !style.display.includes('inline')) {
          emptyBox(clone, rect);
          return;
        }
      }
      if (depth < 7 && el.children.length > 0) walk(el, clone, depth + 1);
    });
  };
  walk(root, copy, 0);
  copy.removeAttribute('id');
  return copy;
}

interface Anchor {
  path: number[];
  top: number;
}

/** A node near the middle of the screen, to correct drift after pruning. */
function findAnchor(root: HTMLElement): Anchor | null {
  const ref = document.elementFromPoint(
    window.innerWidth / 2,
    window.innerHeight * 0.6
  );
  if (!ref || ref === root || !root.contains(ref)) return null;
  const path: number[] = [];
  for (let node: Element = ref; node !== root;) {
    const parent = node.parentElement;
    if (!parent) return null;
    path.unshift(Array.from(parent.children).indexOf(node));
    node = parent;
  }
  return { path, top: ref.getBoundingClientRect().top };
}

function alignToAnchor(holders: HTMLElement[], anchor: Anchor | null) {
  let node: Element | undefined = holders[0];
  if (!anchor || !node) return;
  for (const index of anchor.path) node = node?.children[index];
  if (!node) return;
  const drift = anchor.top - node.getBoundingClientRect().top;
  if (Math.abs(drift) <= 0.5) return;
  for (const holder of holders) {
    holder.style.top = `${parseFloat(holder.style.top) + drift}px`;
  }
}

interface Run {
  layer: HTMLDivElement;
  done: Promise<void>;
  place: (holder: HTMLElement, sliceLeft: number) => void;
  addFace: (face: HTMLDivElement, holder: HTMLElement) => void;
  mount: () => void;
  finish: () => void;
  setFrame: (id: number) => void;
}

/** The overlay that holds the copies, and its lifecycle. */
function createRun(root: HTMLElement): Run {
  const rect = root.getBoundingClientRect();
  const scrollY = window.scrollY;
  const anchor = findAnchor(root);
  const layer = overlayDiv(
    `position:fixed;inset:0;z-index:${TOP_LAYER};pointer-events:none;overflow:hidden`
  );
  layer.setAttribute('aria-hidden', 'true');
  const faces: HTMLDivElement[] = [];
  const holders: HTMLElement[] = [];
  let raf = 0;
  let finished = false;
  let resolve: () => void = () => {};
  const done = new Promise<void>((_resolve) => {
    resolve = _resolve;
  });
  const onScroll = () => {
    for (const face of faces) face.scrollTop = window.scrollY;
  };
  const finish = () => {
    if (finished) return;
    finished = true;
    cancelAnimationFrame(raf);
    window.removeEventListener('scroll', onScroll);
    layer.remove();
    document.documentElement.removeAttribute(SWITCHING);
    if (turnState.finish === finish) turnState.finish = null;
    resolve();
  };
  return {
    layer,
    done,
    finish,
    setFrame: (id) => {
      raf = id;
    },
    place: (holder, sliceLeft) =>
      Object.assign(holder.style, {
        position: 'absolute',
        margin: '0',
        top: `${rect.top + scrollY}px`,
        left: `${rect.left - sliceLeft}px`,
        width: `${rect.width}px`,
      }),
    addFace: (face, holder) => {
      faces.push(face);
      holders.push(holder);
    },
    mount: () => {
      document.body.append(layer);
      onScroll();
      alignToAnchor(holders, anchor);
      window.addEventListener('scroll', onScroll, { passive: true });
      document.documentElement.setAttribute(SWITCHING, '');
      turnState.finish = finish;
    },
  };
}

function crossfade(run: Run, base: HTMLElement, options: TurnOptions) {
  const face = overlayDiv(
    `position:absolute;inset:0;overflow:hidden;background:${options.paper}`
  );
  run.place(base, 0);
  face.append(base);
  run.layer.append(face);
  run.addFace(face, base);
  run.mount();
  void options.commit();
  if (typeof run.layer.animate !== 'function') {
    run.finish();
    return run.done;
  }
  const fade = run.layer.animate([{ opacity: 1 }, { opacity: 0 }], {
    duration: 220,
    easing: 'ease-out',
    fill: 'forwards',
  });
  fade.onfinish = run.finish;
  return run.done;
}

interface Strips {
  strips: HTMLDivElement[];
  overs: HTMLDivElement[];
  shade: HTMLDivElement;
  width: number;
  perspective: number;
}

/** Builds the chained strips, each holding a copy of the page. */
function buildStrips(
  run: Run,
  base: HTMLElement,
  options: TurnOptions
): Strips {
  const W = window.innerWidth;
  const H = window.innerHeight;
  const dir = options.dir;
  const perspective = 3.4 * Math.max(W, H);
  const count = Math.max(6, Math.min(14, Math.round(W / 110)));
  const width = Math.ceil(W / count);
  const side = dir === 1 ? 'left' : 'right';
  const tint = options.dark ? 0.3 : 0.1;
  const shade = overlayDiv('position:absolute;inset:0');
  const scene = overlayDiv(
    `position:absolute;inset:0;perspective:${perspective}px;perspective-origin:${dir === 1 ? 0 : W}px 50%`
  );
  run.layer.append(shade, scene);
  const strips: HTMLDivElement[] = [];
  const overs: HTMLDivElement[] = [];
  let parent: HTMLDivElement = scene;
  for (let i = 0; i < count; i += 1) {
    const left =
      i === 0 ? (dir === 1 ? 0 : W - width) : dir === 1 ? width : -width;
    const strip = overlayDiv(
      `position:absolute;top:0;left:${left}px;height:${H}px;width:${width}px;transform-style:preserve-3d;transform-origin:${side} center;will-change:transform`
    );
    const leaf = overlayDiv(
      `position:absolute;top:0;bottom:0;${side}:0;width:${width + 1}px;overflow:hidden;backface-visibility:hidden;outline:1px solid transparent`
    );
    const face = overlayDiv(
      `position:absolute;inset:0;overflow:hidden;background:${options.paper}`
    );
    const copy = i === 0 ? base : base.cloneNode(true);
    const holder = copy instanceof HTMLElement ? copy : base;
    run.place(holder, dir === 1 ? i * width : W - (i + 1) * width - 1);
    face.append(holder);
    const over = overlayDiv('position:absolute;inset:0;will-change:opacity');
    const back = overlayDiv(
      `position:absolute;inset:0;backface-visibility:hidden;transform:rotateY(180deg);background:linear-gradient(rgba(0,0,0,${tint}),rgba(0,0,0,${tint})),${options.paper}`
    );
    leaf.append(face, over);
    strip.append(leaf, back);
    parent.append(strip);
    parent = strip;
    strips.push(strip);
    overs.push(over);
    run.addFace(face, holder);
  }
  return { strips, overs, shade, width, perspective };
}

const LAG = 0.34;
const MAX_ANGLE = 100;
const RAD = Math.PI / 180;

/** Rotates each strip, shades it, and casts the sheet's shadow. */
function bend(run: Run, built: Strips, options: TurnOptions) {
  const { strips, overs, shade, width, perspective } = built;
  const W = window.innerWidth;
  const dir = options.dir;
  const to = dir === 1 ? 'to right' : 'to left';
  const theta = (s: number, t: number) =>
    MAX_ANGLE * easeInOutCubic(clamp01((t - LAG * s) / (1 - LAG)));
  const kDark = options.dark ? 0.55 : 0.3;
  const kSheen = options.dark ? 0.08 : 0.4;
  const darken = (a: number) =>
    (kDark * (1 - Math.cos(Math.min(a, 90) * RAD))).toFixed(3);
  const sheen = (a: number) =>
    (kSheen * Math.exp(-(((a - 36) / 20) ** 2))).toFixed(3);
  const shadowAlpha = options.dark ? 0.24 : 0.55;
  const duration = options.duration ?? 1150;
  let start = 0;
  const tick = (now: number) => {
    if (!start) start = now;
    const t = Math.min(1, (now - start) / duration);
    let previous = 0;
    let x = 0;
    let z = 0;
    let reach = 0;
    let reachZ = 0;
    strips.forEach((strip, i) => {
      const a = theta((i + 0.5) / strips.length, t);
      const next =
        i < strips.length - 1 ? theta((i + 1.5) / strips.length, t) : a;
      strip.style.transform = `rotateY(${(-dir * (a - previous)).toFixed(3)}deg)`;
      previous = a;
      const over = overs[i];
      if (over) {
        over.style.background = `linear-gradient(${to},rgba(255,255,255,${sheen(a)}),rgba(255,255,255,${sheen(next)})),linear-gradient(${to},rgba(0,0,0,${darken(a)}),rgba(0,0,0,${darken(next)}))`;
      }
      x += width * Math.cos(a * RAD);
      z += width * Math.sin(a * RAD);
      const projected = (x * perspective) / (perspective - z);
      if (projected > reach) {
        reach = projected;
        reachZ = z;
      }
    });
    const lift = clamp01(reachZ / (0.22 * W)) * clamp01(reach / (0.12 * W));
    const alpha = shadowAlpha * lift;
    const spread = 36 + 0.4 * reachZ;
    shade.style.background =
      alpha > 0.002
        ? `linear-gradient(${to},rgba(0,0,0,0) ${(reach - 1).toFixed(1)}px,rgba(0,0,0,${alpha.toFixed(3)}) ${reach.toFixed(1)}px,rgba(0,0,0,${(alpha * 0.3).toFixed(3)}) ${(reach + spread * 0.35).toFixed(1)}px,rgba(0,0,0,0) ${(reach + spread).toFixed(1)}px)`
        : 'none';
    if (t >= 1 || (t > 0.5 && reach < 1)) run.finish();
    else run.setFrame(requestAnimationFrame(tick));
  };
  run.setFrame(requestAnimationFrame(tick));
}

/** Turns the page with the strip fallback, or crossfades (reduced motion). */
export function stripTurn(options: TurnOptions): Promise<void> {
  const base = snapshot(options.root, window.innerHeight);
  if (!base || !document.body) return options.commit();
  const run = createRun(options.root);
  if (options.reduced || typeof run.layer.animate !== 'function') {
    return crossfade(run, base, options);
  }
  const built = buildStrips(run, base, options);
  run.mount();
  void options.commit();
  bend(run, built, options);
  return run.done;
}

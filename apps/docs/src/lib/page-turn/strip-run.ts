import {
  SWITCHING,
  TOP_LAYER,
  emptyBox,
  isOffscreen,
  overlayDiv,
  turnState,
} from './shared';

/**
 * The strip turn's page copy and the overlay that shows it: a pruned
 * clone of the page, kept aligned with the live page while it scrolls.
 */

/** Clone with large off-screen blocks emptied, so strip copies stay light. */
export function snapshot(
  root: HTMLElement,
  height: number
): HTMLElement | null {
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

export interface Run {
  layer: HTMLDivElement;
  done: Promise<void>;
  place: (holder: HTMLElement, sliceLeft: number) => void;
  addFace: (face: HTMLDivElement, holder: HTMLElement) => void;
  mount: () => void;
  finish: () => void;
  setFrame: (id: number) => void;
}

/** The overlay that holds the copies, and its lifecycle. */
export function createRun(root: HTMLElement): Run {
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

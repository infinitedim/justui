/** Scroll-driven motion helpers shared by the landing sequences. */

/** Exponential ease-out: fast start, long settle. */
export function expoOut(t: number): number {
  return t >= 1 ? 1 : 1 - 2 ** (-10 * t);
}

export function clamp01(value: number): number {
  return Math.min(1, Math.max(0, value));
}

/**
 * How far an element has scrolled through a window of the viewport: 0
 * while its top is below `start` (a fraction of the viewport height), 1
 * once it has moved up a further `span` of the viewport height.
 */
export function viewportProgress(
  top: number,
  viewportHeight: number,
  start: number,
  span: number
): number {
  return clamp01((viewportHeight * start - top) / (viewportHeight * span));
}

/** Types and small helpers shared by the page-turn modules. */

export interface TurnOptions {
  /** The page to turn (`[data-page-root]`). */
  root: HTMLElement;
  /** Canvas color of the current theme. */
  paper: string;
  /** Canvas color of the theme being switched to. */
  paperNext: string;
  /** The current theme is dark. */
  dark: boolean;
  /** 1 turns from the right edge (to dark), -1 from the left. */
  dir: 1 | -1;
  /** Play the curl backwards over a still of the old page (to light). */
  reverse: boolean;
  reduced: boolean;
  /** Applies the new theme; resolves once it has painted. */
  commit: () => Promise<void>;
  duration?: number;
}

/** Marks the document while a turn runs; CSS freezes transitions then. */
export const SWITCHING = 'data-theme-switching';

/** Above every page layer, below nothing. */
export const TOP_LAYER = '2147483000';

/** The turn in progress, so a new switch can finish it at once. */
export const turnState: { finish: (() => void) | null } = { finish: null };

/** Cubic ease-in-out. */
export function easeInOutCubic(t: number): number {
  return t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) ** 3 / 2;
}

/** A div with inline styles, for the overlay layers. */
export function overlayDiv(css: string): HTMLDivElement {
  const node = document.createElement('div');
  node.style.cssText = css;
  return node;
}

/** Resolves after `ms` milliseconds. */
export function wait(ms: number): Promise<void> {
  return new Promise((resolve) => window.setTimeout(resolve, ms));
}

/** Resolves after the next two animation frames (one painted frame). */
export function nextPaint(): Promise<void> {
  return new Promise((resolve) =>
    requestAnimationFrame(() => requestAnimationFrame(() => resolve()))
  );
}

/** Empties a clone of an off-screen block, keeping its exact box size. */
export function emptyBox(clone: HTMLElement, rect: DOMRect): void {
  clone.replaceChildren();
  Object.assign(clone.style, {
    boxSizing: 'border-box',
    width: `${rect.width}px`,
    height: `${rect.height}px`,
    minHeight: '0',
    maxHeight: 'none',
    flex: '0 0 auto',
    overflow: 'hidden',
    display: 'block',
  });
}

/** A block well outside the viewport is not worth copying. */
export function isOffscreen(rect: DOMRect, viewportHeight: number): boolean {
  return (
    (rect.width > 0 || rect.height > 0) &&
    (rect.bottom < -120 || rect.top > viewportHeight + 120)
  );
}

/**
 * Makes a page copy safe to put in the document next to the original:
 * named form controls would join the original's radio groups (and uncheck
 * them), so the copy's controls lose their names.
 */
export function detachClone(clone: Element): void {
  for (const control of clone.querySelectorAll('[name]')) {
    if (
      control instanceof HTMLInputElement ||
      control instanceof HTMLSelectElement ||
      control instanceof HTMLTextAreaElement ||
      control instanceof HTMLButtonElement
    ) {
      control.removeAttribute('name');
    }
  }
}

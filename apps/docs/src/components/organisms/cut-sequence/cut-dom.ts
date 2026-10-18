import type { CutFrame, CutGeometry, CutStyle } from '@/lib/cut-sequence';

/**
 * DOM side of the cut sequence: nodes carry `data-cut="<name>"`, so the
 * markup stays plain and only these helpers touch inline styles. They run
 * inside effects and scroll frames, never during render.
 */

function setStyle(root: HTMLElement, name: string, style: CutStyle): void {
  for (const node of root.querySelectorAll<HTMLElement | SVGElement>(
    `[data-cut="${name}"]`
  )) {
    Object.assign(node.style, style);
  }
}

/** Writes one frame of the sequence onto the stage. */
export function applyCutFrame(stage: HTMLElement, frame: CutFrame): void {
  setStyle(stage, 'label', frame.label);
  setStyle(stage, 'scissors', frame.scissors);
  setStyle(stage, 'gate', frame.gate);
  setStyle(stage, 'slot', frame.slot);
  setStyle(stage, 'cut-tag', frame.cutTag);
  setStyle(stage, 'mover', frame.mover);
  setStyle(stage, 'mover-button', frame.moverButton);
  setStyle(stage, 'mover-row', frame.moverRow);
  setStyle(stage, 'folder', frame.folder);
  setStyle(stage, 'landing', frame.landing);
  setStyle(stage, 'shared', frame.shared);
  setStyle(stage, 'verify', frame.verify);
  stage
    .querySelectorAll<HTMLElement>('[data-cut="row"]')
    .forEach((node, index) => {
      Object.assign(node.style, frame.rows[index] ?? {});
    });
}

/**
 * Places the flying copy over the part's slot and returns the offset to
 * its file row. `lift` undoes the slot's current upward nudge.
 */
export function measureCut(stage: HTMLElement, lift: number): CutGeometry {
  const slot = stage.querySelector<HTMLElement>('[data-cut="slot"]');
  const landing = stage.querySelector<HTMLElement>('[data-cut="landing"]');
  const mover = stage.querySelector<HTMLElement>('[data-cut="mover"]');
  if (!slot || !landing || !mover) return { dx: 0, dy: 0 };
  const base = stage.getBoundingClientRect();
  const from = slot.getBoundingClientRect();
  const to = landing.getBoundingClientRect();
  const top = from.top + lift;
  mover.style.left = `${from.left - base.left}px`;
  mover.style.top = `${top - base.top}px`;
  return { dx: to.left - from.left, dy: to.top - top };
}

function clamp01(value: number): number {
  return Math.min(1, Math.max(0, value));
}

/** Progress through a pinned section: 0 when it docks, 1 when it leaves. */
export function pinnedProgress(
  section: HTMLElement,
  sticky: HTMLElement,
  dockTop: number
): number {
  const total = section.offsetHeight - sticky.offsetHeight;
  if (total <= 0) return 1;
  return clamp01((dockTop - section.getBoundingClientRect().top) / total);
}

/**
 * Progress for a stage that scrolls normally: it starts when the stage top
 * passes 80% of the viewport and ends after 90% of its own height.
 */
export function flowProgress(stage: HTMLElement): number {
  const rect = stage.getBoundingClientRect();
  return clamp01(
    (window.innerHeight * 0.8 - rect.top) / Math.max(1, rect.height * 0.9)
  );
}

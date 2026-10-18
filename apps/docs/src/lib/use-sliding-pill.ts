'use client';

import { useLayoutEffect, useRef, type RefObject } from 'react';
import { prefersReducedMotion } from '@/lib/use-reduced-motion';

type Axis = 'x' | 'y';

/** Selector for the currently selected item inside a segmented group. */
const SELECTED =
  '[aria-selected="true"],[aria-pressed="true"],[aria-checked="true"],[aria-current="page"]';

const EASING = 'cubic-bezier(0.45, 0, 0.15, 1)';

interface Box {
  start: number;
  size: number;
}

function lerp(from: number, to: number, amount: number): number {
  return from + (to - from) * amount;
}

function measure(target: HTMLElement, axis: Axis): Box {
  return axis === 'x'
    ? { start: target.offsetLeft, size: target.offsetWidth }
    : { start: target.offsetTop, size: target.offsetHeight };
}

/** Puts the pill exactly over the target, with no animation. */
function place(node: HTMLElement, target: HTMLElement): void {
  Object.assign(node.style, {
    left: `${target.offsetLeft}px`,
    top: `${target.offsetTop}px`,
    width: `${target.offsetWidth}px`,
    height: `${target.offsetHeight}px`,
    opacity: '1',
  });
}

/**
 * Slides an ink pill under the selected item of a segmented group. The
 * leading edge travels first and the trailing edge catches up, so the pill
 * stretches on the way and settles into place (handoff placeSegs/placePill).
 * Position changes happen in a layout effect only (before paint, so the
 * pill never flashes), which keeps the hook React Compiler safe. Once the
 * pill is placed the group gets `data-ready`; until then the selected item
 * paints its own ink background. A resize of the group re-places the pill.
 * Returns the ref for the pill element.
 */
export function useSlidingPill(
  group: RefObject<HTMLElement | null>,
  selectedKey: string,
  axis: Axis,
  duration: number
): RefObject<HTMLSpanElement | null> {
  const pill = useRef<HTMLSpanElement | null>(null);
  const last = useRef<Box | null>(null);

  useLayoutEffect(() => {
    const node = pill.current;
    const host = group.current;
    const target = host?.querySelector<HTMLElement>(SELECTED);
    if (!node || !host || !target) return;
    const next = measure(target, axis);
    place(node, target);
    host.dataset.ready = 'true';
    const previous = last.current;
    last.current = next;
    if (!previous || prefersReducedMotion() || !node.animate) return;
    if (Math.abs(previous.start - next.start) < 1) return;
    const forward = next.start > previous.start;
    const lead = lerp(previous.start, next.start, forward ? 0.22 : 0.78);
    const trail = lerp(
      previous.start + previous.size,
      next.start + next.size,
      forward ? 0.78 : 0.22
    );
    const startProp = axis === 'x' ? 'left' : 'top';
    const sizeProp = axis === 'x' ? 'width' : 'height';
    node.animate(
      [
        {
          [startProp]: `${previous.start}px`,
          [sizeProp]: `${previous.size}px`,
        },
        {
          [startProp]: `${lead}px`,
          [sizeProp]: `${trail - lead}px`,
          offset: 0.45,
        },
        { [startProp]: `${next.start}px`, [sizeProp]: `${next.size}px` },
      ],
      { duration, easing: EASING }
    );
  }, [group, selectedKey, axis, duration]);

  // Item sizes change after the first paint (web font swap, window resize,
  // rotation). Follow them without animating.
  useLayoutEffect(() => {
    const host = group.current;
    if (!host || typeof ResizeObserver === 'undefined') return;
    const observer = new ResizeObserver(() => {
      const node = pill.current;
      const target = host.querySelector<HTMLElement>(SELECTED);
      if (!node || !target) return;
      place(node, target);
      last.current = measure(target, axis);
    });
    observer.observe(host);
    return () => observer.disconnect();
  }, [group, axis]);

  return pill;
}

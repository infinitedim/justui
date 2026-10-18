'use client';

import { useLayoutEffect, useRef, useState, type RefObject } from 'react';
import { cutFrame, type CutGeometry } from '@/lib/cut-sequence';
import { useReducedMotion } from '@/lib/use-reduced-motion';
import { useScrollFrame } from '@/lib/use-scroll-frame';
import {
  applyCutFrame,
  flowProgress,
  measureCut,
  pinnedProgress,
} from './cut-dom';
import type { CutMode } from './cut-sequence.types';

/** Height of the sticky site nav the pinned stage docks under. */
const DOCK_TOP = 64;
/** Vertical padding around the content inside the pinned frame (py-10). */
const FRAME_PADDING = 80;

interface CutRefs {
  section: RefObject<HTMLElement | null>;
  sticky: RefObject<HTMLDivElement | null>;
  content: RefObject<HTMLDivElement | null>;
  stage: RefObject<HTMLDivElement | null>;
}

/** Calls `onChange` when any node resizes, the window resizes or fonts load. */
function observeLayout(nodes: readonly Element[], onChange: () => void) {
  let live = true;
  const run = () => {
    if (live) onChange();
  };
  const observer =
    typeof ResizeObserver === 'undefined' ? null : new ResizeObserver(run);
  for (const node of nodes) observer?.observe(node);
  window.addEventListener('resize', run);
  void document.fonts?.ready.then(run);
  return () => {
    live = false;
    observer?.disconnect();
    window.removeEventListener('resize', run);
  };
}

/** Whether the content fits under the nav, so the stage can be pinned. */
function useFitsViewport(content: RefObject<HTMLDivElement | null>) {
  const [fits, setFits] = useState<boolean | null>(null);
  useLayoutEffect(() => {
    const node = content.current;
    if (!node) return;
    const check = () =>
      setFits(
        node.offsetHeight + FRAME_PADDING <= window.innerHeight - DOCK_TOP
      );
    check();
    return observeLayout([node], check);
  }, [content]);
  return fits;
}

/**
 * Drives the cut sequence. The prerendered page is the finished layout
 * (`rest`); in the browser the stage is pinned and scrubbed by scroll, or
 * scrubbed in place when it does not fit, or (reduced motion) switched
 * between before and after with fades.
 */
export function useCutMotion(refs: CutRefs, rows: number) {
  const reduced = useReducedMotion();
  const fits = useFitsViewport(refs.content);
  const [after, setAfter] = useState(true);
  const geometry = useRef<CutGeometry>({ dx: 0, dy: 0 });
  const lift = useRef(0);
  const mode: CutMode = reduced
    ? 'stepped'
    : fits === null
      ? 'rest'
      : fits
        ? 'pinned'
        : 'flow';
  const scrubbing = mode === 'pinned' || mode === 'flow';

  // The flight path, re-measured when layout, fonts or the preset change.
  useLayoutEffect(() => {
    const stage = refs.stage.current;
    if (!stage || !scrubbing) return;
    const measure = () => {
      geometry.current = measureCut(stage, lift.current);
    };
    measure();
    const slot = stage.querySelector('[data-cut="slot"]');
    return observeLayout(slot ? [stage, slot] : [stage], measure);
  }, [refs.stage, scrubbing]);

  useScrollFrame(scrubbing, () => {
    const section = refs.section.current;
    const sticky = refs.sticky.current;
    const stage = refs.stage.current;
    if (!section || !sticky || !stage) return;
    const p =
      mode === 'pinned'
        ? pinnedProgress(section, sticky, DOCK_TOP)
        : flowProgress(stage);
    const frame = cutFrame(p, {
      stepped: false,
      geometry: geometry.current,
      rows,
    });
    lift.current = frame.lift;
    applyCutFrame(stage, frame);
  });

  useLayoutEffect(() => {
    const stage = refs.stage.current;
    if (!stage || mode !== 'stepped') return;
    applyCutFrame(
      stage,
      cutFrame(after ? 1 : 0, {
        stepped: true,
        geometry: geometry.current,
        rows,
      })
    );
  }, [refs.stage, mode, after, rows]);

  return { mode, after, setAfter };
}

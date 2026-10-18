'use client';

// Client leaf: the ink field wipes in as the demo scrolls into view.
import { useLayoutEffect, useRef } from 'react';
import { PresetStage } from '@/components/organisms/preset-stage';
import { KitButton } from '@/components/runner-kit/kit-actions';
import { expoOut, viewportProgress } from '@/lib/scroll-progress';
import { useReducedMotion } from '@/lib/use-reduced-motion';
import { useScrollFrame } from '@/lib/use-scroll-frame';
import type { TextWipeProps } from './feature-rows.types';

/** At rest the ink field covers the right half. */
const REST = 'inset(0 0 0 50%)';

function ButtonGroup({
  save,
  saveDraft,
  hidden,
}: {
  save: string;
  saveDraft: string;
  /** Covered at rest: out of the tab order and the accessibility tree. */
  hidden: boolean;
}) {
  return (
    <div
      inert={hidden}
      className="flex flex-wrap items-center justify-center gap-2 px-2"
    >
      <KitButton>{save}</KitButton>
      <KitButton variant="secondary">{saveDraft}</KitButton>
    </div>
  );
}

/**
 * "Text follows the background": the same buttons on paper and on ink.
 * Each half holds its own group, so at rest nothing straddles the seam;
 * mid-wipe the right group is half paper, half ink.
 */
export function TextWipe({ onPaper, onInk, save, saveDraft }: TextWipeProps) {
  const reduced = useReducedMotion();
  const wipe = useRef<HTMLDivElement | null>(null);
  const ink = useRef<HTMLDivElement | null>(null);
  useScrollFrame(!reduced, () => {
    if (!wipe.current || !ink.current) return;
    const top = wipe.current.getBoundingClientRect().top;
    const p = expoOut(viewportProgress(top, window.innerHeight, 0.92, 0.5));
    ink.current.style.clipPath = `inset(0 0 0 ${100 - 50 * p}%)`;
  });
  useLayoutEffect(() => {
    if (reduced && ink.current) ink.current.style.clipPath = REST;
  }, [reduced]);
  const group = { save, saveDraft };
  return (
    <div
      ref={wipe}
      className="border-ip-border-subtle relative h-[172px] min-w-0 overflow-hidden rounded-[12px] border"
    >
      <PresetStage
        animated={false}
        className="bg-ip-canvas absolute inset-0 flex flex-col px-[18px] py-4"
      >
        <span className="text-ip-text-tertiary text-[13px] font-semibold">
          {onPaper}
        </span>
        <div className="grid flex-1 grid-cols-2 items-center">
          <ButtonGroup {...group} hidden={false} />
          <ButtonGroup {...group} hidden />
        </div>
      </PresetStage>
      <div
        ref={ink}
        className="ink-paper-invert absolute inset-0 bg-(--ip-band) [clip-path:inset(0_0_0_50%)]"
      >
        <PresetStage
          animated={false}
          className="flex h-full flex-col px-[18px] py-4"
        >
          <span className="text-ip-text-tertiary self-end text-[13px] font-semibold">
            {onInk}
          </span>
          <div className="grid flex-1 grid-cols-2 items-center">
            <ButtonGroup {...group} hidden />
            <ButtonGroup {...group} hidden={false} />
          </div>
        </PresetStage>
      </div>
    </div>
  );
}

'use client';

// Client leaf: the "In your hand" chip follows the visitor's preset and
// the second column slides out from under the first on scroll.
import { useLayoutEffect, useRef } from 'react';
import { PresetSwatch } from '@/components/atoms/preset-swatch';
import { PresetStage } from '@/components/organisms/preset-stage';
import { usePreset } from '@/components/providers';
import { cn } from '@/lib/cn';
import { getKitDictionary } from '@/lib/kit-translations';
import { getLandingDictionary } from '@/lib/landing-translations';
import { PRESET_LABELS } from '@/lib/presets';
import { expoOut, viewportProgress } from '@/lib/scroll-progress';
import { useReducedMotion } from '@/lib/use-reduced-motion';
import { useScrollFrame } from '@/lib/use-scroll-frame';
import { SettingsScreen } from './settings-screen';
import type { RunnerColumnProps, TwoRunnersProps } from './two-runners.types';

const rest = { transform: 'none', willChange: 'auto' } as const;

/**
 * While the split scrolls into view, the second column starts stacked
 * under the first and slides out to sit beside it. Only when the columns
 * really sit side by side; otherwise (and at rest) it stays in place.
 */
function slideApart(
  split: HTMLElement | null,
  first: HTMLElement | null,
  second: HTMLElement | null
) {
  if (!split || !first || !second) return;
  const dx = second.offsetLeft - first.offsetLeft;
  const sideBySide = Math.abs(second.offsetTop - first.offsetTop) < 4 && dx > 0;
  if (!sideBySide) {
    Object.assign(second.style, rest);
    return;
  }
  const top = split.getBoundingClientRect().top;
  const p = expoOut(viewportProgress(top, window.innerHeight, 0.95, 0.6));
  Object.assign(second.style, {
    transform: `translate3d(${-dx * (1 - p)}px, 0, 0)`,
    willChange: p > 0 && p < 1 ? 'transform' : 'auto',
  });
}

function RunnerColumn({
  preset,
  inHand,
  current,
  columnRef,
  className,
  children,
}: RunnerColumnProps) {
  return (
    <div
      ref={columnRef}
      className={cn(
        'relative flex min-w-0 flex-[1_1_420px] flex-col gap-3.5',
        className
      )}
    >
      <div className="flex min-h-8 items-center gap-3">
        <PresetSwatch preset={preset} size={28} />
        <span className="text-base font-semibold">{PRESET_LABELS[preset]}</span>
        {preset === current ? (
          <span className="bg-ip-inverse text-ip-on-inverse flex h-6.5 items-center rounded-[6px] px-2.5 text-xs font-semibold">
            {inHand}
          </span>
        ) : null}
      </div>
      <PresetStage
        preset={preset}
        animated={false}
        className="bg-ip-sunken flex flex-1 flex-col items-start gap-5 rounded-[16px] p-[clamp(20px,3vw,40px)]"
      >
        {children}
      </PresetStage>
    </div>
  );
}

/** "Same parts, two runners.": one screen in each preset, side by side. */
export function TwoRunners({ lang }: TwoRunnersProps) {
  const t = getLandingDictionary(lang);
  const kit = getKitDictionary(lang);
  const { preset } = usePreset();
  const reduced = useReducedMotion();
  const split = useRef<HTMLDivElement | null>(null);
  const first = useRef<HTMLDivElement | null>(null);
  const second = useRef<HTMLDivElement | null>(null);
  useScrollFrame(!reduced, () =>
    slideApart(split.current, first.current, second.current)
  );
  useLayoutEffect(() => {
    if (reduced && second.current) Object.assign(second.current.style, rest);
  }, [reduced]);
  return (
    <section
      aria-labelledby="landing-runners"
      className="border-ip-border-subtle border-t"
    >
      <div className="mx-auto max-w-360 px-[clamp(20px,4vw,48px)] py-[clamp(72px,9vw,128px)]">
        <div className="flex flex-wrap items-end justify-between gap-x-12 gap-y-4">
          <h2
            id="landing-runners"
            className="max-w-[18ch] text-[clamp(32px,4.2vw,56px)] leading-[1.06] font-bold tracking-[-0.03em] text-balance"
          >
            {t.runnersTitle}
          </h2>
          <p className="text-ip-text-secondary max-w-[50ch] text-[17px] leading-[1.6]">
            {t.runnersLead}
          </p>
        </div>
        <div
          ref={split}
          className="mt-[clamp(32px,4vw,48px)] flex flex-wrap gap-6"
        >
          <RunnerColumn
            preset="default"
            inHand={t.inHand}
            current={preset}
            columnRef={first}
            className="bg-ip-canvas z-2"
          >
            <SettingsScreen kit={kit} />
          </RunnerColumn>
          <RunnerColumn
            preset="neobrutalism"
            inHand={t.inHand}
            current={preset}
            columnRef={second}
            className="z-1"
          >
            <SettingsScreen kit={kit} />
          </RunnerColumn>
        </div>
      </div>
    </section>
  );
}

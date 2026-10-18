'use client';

// Client leaf: chooses the preset every stage region renders with.
import { useId, useRef } from 'react';
import { PresetSwatch } from '@/components/atoms/preset-swatch';
import { usePreset } from '@/components/providers';
import { cn } from '@/lib/cn';
import { animatePresetSwap } from '@/lib/preset-swap';
import { PRESET_LABELS, PRESETS, type JustUIPreset } from '@/lib/presets';
import { useRovingTabs } from '@/lib/use-roving-tabs';
import { useSlidingPill } from '@/lib/use-sliding-pill';
import type { RunnerShelfProps } from './runner-shelf.types';

/**
 * Vertical list of runners (presets). One ink pill slides to the chosen
 * runner (handoff placePill, 560ms) and the stages cross-dissolve.
 */
export function RunnerShelf({
  heading,
  label,
  notes,
  className,
}: RunnerShelfProps) {
  const headingId = useId();
  const { preset, setPreset } = usePreset();
  const group = useRef<HTMLDivElement | null>(null);
  const pill = useSlidingPill(group, preset, 'y', 560);

  function choose(next: JustUIPreset) {
    if (next !== preset) animatePresetSwap(() => setPreset(next));
  }

  const { registerTab, onKeyDown } = useRovingTabs(PRESETS, preset, choose);

  return (
    <div className={cn('flex flex-col gap-2.5', className)}>
      <span
        id={headingId}
        className="text-ip-text-tertiary text-[13px] font-semibold"
      >
        {heading}
      </span>
      <div
        ref={group}
        role="radiogroup"
        aria-label={label}
        aria-describedby={headingId}
        className="group/shelf relative flex flex-col gap-1"
      >
        <span
          ref={pill}
          aria-hidden="true"
          className="bg-ip-inverse pointer-events-none absolute top-0 left-0 w-full rounded-[12px] opacity-0"
        />
        {PRESETS.map((id) => {
          const selected = id === preset;
          return (
            <button
              key={id}
              ref={registerTab(id)}
              type="button"
              role="radio"
              aria-checked={selected}
              tabIndex={selected ? 0 : -1}
              onClick={() => choose(id)}
              onKeyDown={onKeyDown}
              className={cn(
                'relative z-1 flex w-full cursor-pointer items-center gap-3.5 rounded-[12px] px-3 py-2.5 text-left transition-colors duration-360',
                selected
                  ? 'bg-ip-inverse text-ip-on-inverse group-data-ready/shelf:bg-transparent'
                  : 'text-ip-text-primary hover:bg-ip-hover'
              )}
            >
              <PresetSwatch preset={id} />
              <span className="flex min-w-0 flex-col items-start gap-0.5">
                <span className="text-[15px] font-semibold">
                  {PRESET_LABELS[id]}
                </span>
                <span
                  className={cn(
                    'text-[13px] leading-[18px]',
                    selected ? 'text-ip-on-inverse' : 'text-ip-text-secondary'
                  )}
                >
                  {notes[id]}
                </span>
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

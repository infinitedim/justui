'use client';

// Client leaf: selection state and the sliding ink pill.
import { useRef } from 'react';
import { cn } from '@/lib/cn';
import { useRovingTabs } from '@/lib/use-roving-tabs';
import { useSlidingPill } from '@/lib/use-sliding-pill';
import type { SegmentedPillProps } from './segmented-pill.types';

/**
 * Segmented control whose selected item sits on one ink pill that slides
 * sideways with a stretch (handoff placeSegs, 520ms).
 */
export function SegmentedPill<T extends string>({
  label,
  options,
  value,
  onChange,
  kind = 'tabs',
  className,
}: SegmentedPillProps<T>) {
  const group = useRef<HTMLDivElement | null>(null);
  const pill = useSlidingPill(group, value, 'x', 520);
  const ids = options.map((option) => option.value);
  const { registerTab, onKeyDown } = useRovingTabs(ids, value, onChange);
  const isTabs = kind === 'tabs';
  return (
    <div
      ref={group}
      role={isTabs ? 'tablist' : 'group'}
      aria-label={label}
      className={cn('group/seg relative flex items-center gap-1', className)}
    >
      <span
        ref={pill}
        aria-hidden="true"
        className="bg-ip-inverse pointer-events-none absolute top-0 left-0 h-8 rounded-[6px] opacity-0"
      />
      {options.map((option) => {
        const selected = option.value === value;
        return (
          <button
            key={option.value}
            ref={isTabs ? registerTab(option.value) : undefined}
            type="button"
            role={isTabs ? 'tab' : undefined}
            aria-selected={isTabs ? selected : undefined}
            aria-pressed={isTabs ? undefined : selected}
            tabIndex={isTabs && !selected ? -1 : 0}
            onClick={() => onChange(option.value)}
            onKeyDown={isTabs ? onKeyDown : undefined}
            className={cn(
              'relative z-1 h-8 shrink-0 cursor-pointer rounded-[6px] px-3 text-[13px] font-semibold whitespace-nowrap transition-colors duration-300',
              selected
                ? 'text-ip-on-inverse group-data-ready/seg:bg-transparent'
                : 'text-ip-text-secondary hover:text-ip-text-primary'
            )}
          >
            {option.label}
          </button>
        );
      })}
    </div>
  );
}

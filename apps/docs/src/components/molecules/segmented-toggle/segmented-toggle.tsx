'use client';

import { cn } from '@/lib/cn';

export interface SegmentedOption<T extends string> {
  value: T;
  label: string;
}

export interface SegmentedToggleProps<T extends string> {
  value: T;
  options: readonly [SegmentedOption<T>, SegmentedOption<T>, ...SegmentedOption<T>[]];
  onChange: (value: T) => void;
  /** Accessible name of the radio group. */
  label: string;
  className?: string;
}

/**
 * Compact segmented control. Every option is visible; the active one is
 * filled with the accent. Follows the active preset: border width, corner
 * radius and the xs offset shadow all come from --just-* tokens.
 */
export function SegmentedToggle<T extends string>({
  value,
  options,
  onChange,
  label,
  className,
}: SegmentedToggleProps<T>) {
  return (
    <div
      role="radiogroup"
      aria-label={label}
      className={cn(
        'bg-card border-border inline-flex overflow-hidden',
        'rounded-(--just-radius-md) border-(length:--just-border-width) shadow-xs',
        className
      )}
    >
      {options.map((option, index) => {
        const active = option.value === value;
        return (
          <button
            key={option.value}
            type="button"
            role="radio"
            aria-checked={active}
            onClick={() => onChange(option.value)}
            className={cn(
              'h-7 px-2.5 font-mono text-xs transition-colors',
              index > 0 && 'border-border border-l-(length:--just-border-width)',
              active
                ? 'bg-accent text-accent-foreground font-semibold'
                : 'text-muted hover:text-foreground font-normal'
            )}
          >
            {option.label}
          </button>
        );
      })}
    </div>
  );
}

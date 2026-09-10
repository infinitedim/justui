'use client';

import { cn } from '@/lib/cn';
import type { StateToggleProps } from './state-toggle.types';

/**
 * Boolean state toggle molecule for component playground controls.
 * Renders a labeled inline switch using ARIA switch role.
 */
export function StateToggle({
  value,
  onChange,
  label,
  className,
}: StateToggleProps) {
  return (
    <label
      className={cn(
        'text-secondary inline-flex cursor-pointer items-center gap-2 font-mono text-xs',
        className
      )}
    >
      <button
        type="button"
        role="switch"
        aria-checked={value}
        onClick={() => onChange(!value)}
        className={cn(
          'relative inline-flex h-5 w-9 shrink-0 items-center rounded-full transition-colors',
          'border-border border-(length:--just-border-width)',
          'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
          value ? 'bg-accent' : 'bg-border'
        )}
      >
        <span
          className={cn(
            'inline-block h-3.5 w-3.5 rounded-full bg-white transition-transform',
            'shadow-solid',
            value ? 'translate-x-4' : 'translate-x-0.5'
          )}
          aria-hidden="true"
        />
      </button>
      <span>{label}</span>
    </label>
  );
}

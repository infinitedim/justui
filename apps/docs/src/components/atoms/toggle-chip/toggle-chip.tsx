'use client';

import { cn } from '@/lib/cn';
import type { ToggleChipProps } from './toggle-chip.types';

/**
 * Toggleable chip/pill atom for filter selections and category toggles.
 * Client Component for click interaction.
 */
export function ToggleChip({
  active = false,
  className,
  children,
  ...rest
}: ToggleChipProps) {
  return (
    <button
      type="button"
      aria-pressed={active}
      className={cn(
        'inline-flex items-center rounded-full px-3 py-1 font-mono text-xs font-medium transition-colors',
        'border-(length:--just-border-width)',
        'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
        active
          ? 'border-accent bg-accent-muted text-accent-deep shadow-solid'
          : 'border-border text-muted hover:text-foreground hover:border-foreground/20 bg-transparent',
        className
      )}
      {...rest}
    >
      {children}
    </button>
  );
}

'use client';

import { cn } from '@/lib/cn';
import type { CategoryFilterPillProps } from './category-filter-pill.types';

/**
 * Category filter pill molecule for the component catalog.
 * Composes ToggleChip behavior with a count badge.
 */
export function CategoryFilterPill({
  label,
  count,
  active = false,
  onClick,
  className,
}: CategoryFilterPillProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      className={cn(
        'inline-flex items-center gap-1.5 rounded-full px-3 py-1 font-mono text-xs font-medium transition-colors',
        'border-(length:--just-border-width)',
        'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
        active
          ? 'border-accent bg-accent-muted text-accent-dark dark:text-accent-light shadow-solid'
          : 'border-border text-muted hover:text-foreground bg-transparent',
        className
      )}
    >
      <span>{label}</span>
      {count !== undefined ? (
        <span
          className={cn(
            'inline-flex h-4 min-w-4 items-center justify-center rounded-full px-1 text-[10px]',
            active
              ? 'bg-accent font-semibold text-[#18181b]'
              : 'bg-border text-secondary'
          )}
        >
          {count}
        </span>
      ) : null}
    </button>
  );
}

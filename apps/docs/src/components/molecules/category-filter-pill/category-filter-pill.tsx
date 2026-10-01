'use client';

import { cn } from '@/lib/cn';
import type { CategoryFilterPillProps } from './category-filter-pill.types';

/**
 * Category filter button for the component catalog. Uses the preset's
 * radius token, so it is square under neobrutalism like every other control.
 */
export function CategoryFilterPill({
  label,
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
        'inline-flex h-8 items-center rounded-(--just-radius-md) px-3 text-sm transition-colors',
        'border-(length:--just-border-width)',
        'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
        active
          ? 'border-border bg-accent text-accent-foreground font-medium'
          : 'text-secondary hover:text-foreground hover:bg-card border-transparent',
        className
      )}
    >
      {label}
    </button>
  );
}

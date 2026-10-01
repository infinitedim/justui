'use client';

import { cn } from '@/lib/cn';
import type { CategoryFilterPillProps } from './category-filter-pill.types';

/**
 * Category filter chip for the component catalog. Shape, border and shadow
 * come from the active preset's tokens.
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
          ? 'border-border bg-accent text-accent-foreground font-medium shadow-xs'
          : 'text-muted hover:text-foreground border-transparent bg-transparent',
        className
      )}
    >
      {label}
    </button>
  );
}

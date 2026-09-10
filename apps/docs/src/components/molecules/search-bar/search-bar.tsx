'use client';

import { cn } from '@/lib/cn';
import { Kbd } from '@/components/atoms/kbd';
import type { SearchBarProps } from './search-bar.types';

/**
 * Search trigger bar molecule. Composes Kbd atom for the shortcut indicator.
 * Client Component for onClick interaction.
 */
export function SearchBar({
  shortcut = 'Ctrl K',
  placeholder = 'Search...',
  onActivate,
  label = 'Open search',
  className,
}: SearchBarProps) {
  return (
    <button
      type="button"
      onClick={onActivate}
      aria-label={label}
      className={cn(
        'hidden items-center gap-3 rounded-full bg-transparent px-3 py-1.5 font-mono text-xs transition-colors sm:flex',
        'border-border border-(length:--just-border-width)',
        'text-muted hover:text-foreground',
        className
      )}
    >
      <span>{placeholder}</span>
      <Kbd>{shortcut}</Kbd>
    </button>
  );
}

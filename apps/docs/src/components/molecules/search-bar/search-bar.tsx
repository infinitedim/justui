'use client';

import { Search } from 'lucide-react';
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
        'just-press bg-card text-muted hover:text-foreground flex max-sm:hidden h-7 items-center gap-2.5 px-2.5 font-mono text-xs',
        'rounded-(--just-radius-md) border-(length:--just-border-width) border-border shadow-xs',
        className
      )}
    >
      <Search size={13} className="text-muted shrink-0" aria-hidden="true" />
      <span className="whitespace-nowrap">{placeholder}</span>
      <Kbd className="whitespace-nowrap">{shortcut}</Kbd>
    </button>
  );
}

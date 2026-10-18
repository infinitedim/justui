'use client';

// Client leaf: opens the fumadocs search dialog from the page nav.
import { Search } from 'lucide-react';
import { useSearchContext } from 'fumadocs-ui/contexts/search';
import { cn } from '@/lib/cn';
import type { SearchTriggerProps } from './search-trigger.types';

/** "Search docs" button with the Ctrl K hint; Ctrl K itself is global. */
export function SearchTrigger({ label, className }: SearchTriggerProps) {
  const { setOpenSearch } = useSearchContext();
  return (
    <button
      type="button"
      aria-keyshortcuts="Control+K Meta+K"
      onClick={() => setOpenSearch(true)}
      className={cn(
        'bg-ip-sunken text-ip-text-secondary hover:text-ip-text-primary flex h-9 shrink-0 cursor-pointer items-center gap-2.5 rounded-[8px] pr-1.5 pl-3 text-sm font-medium whitespace-nowrap',
        className
      )}
    >
      <Search size={15} aria-hidden="true" />
      <span>{label}</span>
      <kbd
        aria-hidden="true"
        className="bg-ip-surface text-ip-text-secondary rounded-[4px] px-2 py-0.75 font-mono text-xs"
      >
        Ctrl K
      </kbd>
    </button>
  );
}

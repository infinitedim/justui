'use client';

import { useRef, useEffect } from 'react';
import { Search, X } from 'lucide-react';
import { cn } from '@/lib/cn';
import { CATEGORIES } from '@/lib/components-data';
import type { ComponentCategory } from '@/lib/components-data';
import { CategoryFilterPill } from '@/components/molecules/category-filter-pill';
import { Kbd } from '@/components/atoms/kbd';

export interface CatalogFilterBarProps {
  searchQuery: string;
  onSearchChange: (q: string) => void;
  activeCategory: string;
  onCategoryChange: (cat: string) => void;
  searchPlaceholder: string;
  searchLabel: string;
  categoryLabel: string;
  allLabel: string;
  categoryLabels: Record<ComponentCategory, string>;
  className?: string;
}

export function CatalogFilterBar({
  searchQuery,
  onSearchChange,
  activeCategory,
  onCategoryChange,
  searchPlaceholder,
  searchLabel,
  categoryLabel,
  allLabel,
  categoryLabels,
  className,
}: CatalogFilterBarProps) {
  const inputRef = useRef<HTMLInputElement>(null);

  // "/" focuses the search field, Escape clears it.
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (
        e.key === '/' &&
        document.activeElement !== inputRef.current &&
        !(e.target instanceof HTMLInputElement) &&
        !(e.target instanceof HTMLTextAreaElement)
      ) {
        e.preventDefault();
        inputRef.current?.focus();
      } else if (
        e.key === 'Escape' &&
        document.activeElement === inputRef.current
      ) {
        onSearchChange('');
        inputRef.current?.blur();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onSearchChange]);

  return (
    <div
      data-testid="catalog-filter-bar"
      className={cn('space-y-3', className)}
    >
      <div className="bg-card border-border focus-within:outline-accent relative flex h-10 items-center rounded-(--just-radius-md) border-(length:--just-border-width) focus-within:outline-2 focus-within:outline-offset-2 sm:max-w-md">
        <Search
          className="text-muted ml-3 h-4 w-4 shrink-0"
          aria-hidden="true"
        />
        <input
          ref={inputRef}
          type="search"
          value={searchQuery}
          onChange={(e) => onSearchChange(e.target.value)}
          placeholder={searchPlaceholder}
          aria-label={searchLabel}
          data-testid="catalog-search-input"
          className="placeholder:text-muted w-full bg-transparent px-3 text-sm outline-none [&::-webkit-search-cancel-button]:hidden"
        />
        {searchQuery ? (
          <button
            type="button"
            onClick={() => {
              onSearchChange('');
              inputRef.current?.focus();
            }}
            aria-label="Clear search"
            className="text-muted hover:text-foreground mr-2 p-1"
          >
            <X className="h-4 w-4" aria-hidden="true" />
          </button>
        ) : (
          <Kbd className="mr-3 hidden sm:inline-flex" aria-hidden="true">
            /
          </Kbd>
        )}
      </div>

      <div
        role="group"
        aria-label={categoryLabel}
        className="flex flex-wrap items-center gap-1"
      >
        <CategoryFilterPill
          label={allLabel}
          active={activeCategory === 'all'}
          onClick={() => onCategoryChange('all')}
        />
        {CATEGORIES.map((cat) => (
          <CategoryFilterPill
            key={cat}
            label={categoryLabels[cat]}
            active={activeCategory === cat}
            onClick={() => onCategoryChange(cat)}
          />
        ))}
      </div>
    </div>
  );
}

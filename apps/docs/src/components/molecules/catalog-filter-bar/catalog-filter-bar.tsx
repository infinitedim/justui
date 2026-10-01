'use client';

import { useEffect, useRef } from 'react';
import { Search, X } from 'lucide-react';
import { cn } from '@/lib/cn';
import { CATEGORY_ORDER, type ComponentCategory } from '@/lib/components-data';
import { CategoryFilterPill } from '@/components/molecules/category-filter-pill';
import { Kbd } from '@/components/atoms/kbd';
import type { CatalogUiStrings } from '@/lib/catalog-i18n';
import { focusRing, surface } from '@/lib/ui-classes';

export type CategoryFilter = ComponentCategory | 'all';

export interface CatalogFilterBarProps {
  searchQuery: string;
  onSearchChange: (query: string) => void;
  activeCategory: CategoryFilter;
  onCategoryChange: (category: CategoryFilter) => void;
  ui: CatalogUiStrings;
  className?: string;
}

/**
 * Search field and category chips. "/" focuses the search, Escape clears it.
 * The active preset is not controlled here: it is the navbar's PresetToggle.
 */
export function CatalogFilterBar({
  searchQuery,
  onSearchChange,
  activeCategory,
  onCategoryChange,
  ui,
  className,
}: CatalogFilterBarProps) {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      const typing =
        e.target instanceof HTMLInputElement ||
        e.target instanceof HTMLTextAreaElement ||
        (e.target instanceof HTMLElement && e.target.isContentEditable);
      if (e.key === '/' && !typing) {
        e.preventDefault();
        inputRef.current?.focus();
        return;
      }
      if (e.key === 'Escape' && document.activeElement === inputRef.current) {
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
      className={cn('space-y-4', className)}
    >
      <div
        className={cn(
          surface,
          'focus-within:outline-accent relative flex max-w-xl items-center focus-within:outline-2 focus-within:outline-offset-2'
        )}
      >
        <Search
          className="text-muted ml-3 h-4 w-4 shrink-0"
          aria-hidden="true"
        />
        <input
          ref={inputRef}
          type="search"
          value={searchQuery}
          onChange={(e) => onSearchChange(e.target.value)}
          placeholder={ui.searchPlaceholder}
          aria-label={ui.searchLabel}
          data-testid="catalog-search-input"
          className="placeholder:text-muted text-foreground w-full bg-transparent px-3 py-2 text-sm outline-none [&::-webkit-search-cancel-button]:hidden"
        />
        {searchQuery ? (
          <button
            type="button"
            onClick={() => {
              onSearchChange('');
              inputRef.current?.focus();
            }}
            aria-label={ui.clearSearch}
            className={cn(
              focusRing,
              'text-muted hover:text-foreground mr-2 rounded-(--just-radius-sm) p-1'
            )}
          >
            <X className="h-3.5 w-3.5" aria-hidden="true" />
          </button>
        ) : (
          <Kbd className="mr-3 hidden sm:inline-flex" aria-hidden="true">
            /
          </Kbd>
        )}
      </div>

      <div
        role="group"
        aria-label={ui.categoriesLabel}
        className="flex flex-wrap items-center gap-1.5"
      >
        <CategoryFilterPill
          label={ui.allCategories}
          active={activeCategory === 'all'}
          onClick={() => onCategoryChange('all')}
        />
        {CATEGORY_ORDER.map((id) => (
          <CategoryFilterPill
            key={id}
            label={ui.categories[id]}
            active={activeCategory === id}
            onClick={() => onCategoryChange(id)}
          />
        ))}
      </div>
    </div>
  );
}

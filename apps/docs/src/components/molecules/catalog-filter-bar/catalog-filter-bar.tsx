'use client';

import React, { useRef, useEffect } from 'react';
import { cn } from '@/lib/cn';
import { CATEGORIES } from '@/lib/components-data';
import { CategoryFilterPill } from '@/components/molecules/category-filter-pill';
import { Search, X } from 'lucide-react';
import { Kbd } from '@/components/atoms/kbd';

export interface CatalogFilterBarProps {
  searchQuery: string;
  onSearchChange: (q: string) => void;
  activeCategory: string;
  onCategoryChange: (cat: string) => void;
  categoryCounts: Record<string, number>;
  totalCount: number;
  preset: 'default' | 'neobrutalism';
  onPresetChange: (p: 'default' | 'neobrutalism') => void;
  searchPlaceholder?: string;
  allLabel?: string;
  presetLabel?: string;
  className?: string;
}

export function CatalogFilterBar({
  searchQuery,
  onSearchChange,
  activeCategory,
  onCategoryChange,
  categoryCounts,
  totalCount,
  preset,
  onPresetChange,
  searchPlaceholder = 'Search 33 components...',
  allLabel = 'All',
  presetLabel = 'Preset',
  className,
}: CatalogFilterBarProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const isNeo = preset === 'neobrutalism';

  // Hotkey "/" to focus search, "Escape" to clear
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
      className={cn('space-y-4', className)}
    >
      {/* Top Bar: Search Input & Preset Switcher */}
      <div className="flex flex-col items-stretch justify-between gap-3 sm:flex-row sm:items-center">
        {/* Search Input */}
        <div
          className={cn(
            'bg-surface relative flex flex-1 items-center transition-all',
            isNeo
              ? 'rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
              : 'border-border focus-within:ring-accent rounded-lg border focus-within:ring-1'
          )}
        >
          <Search className="text-muted ml-3 h-4 w-4 shrink-0" />
          <input
            ref={inputRef}
            type="text"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder={searchPlaceholder}
            aria-label="Search components"
            data-testid="catalog-search-input"
            className="placeholder:text-muted w-full bg-transparent px-3 py-2 font-mono text-xs outline-none"
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
              <X className="h-3.5 w-3.5" />
            </button>
          ) : (
            <div className="mr-3 hidden items-center gap-1 sm:flex">
              <Kbd>/</Kbd>
            </div>
          )}
        </div>

        {/* Preset Switcher */}
        <div
          data-testid="catalog-preset-toggle"
          className={cn(
            'bg-surface inline-flex items-center gap-1 self-start p-1 font-mono text-xs select-none sm:self-auto',
            isNeo
              ? 'rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
              : 'border-border rounded-lg border'
          )}
        >
          <span className="text-muted hidden px-2 text-[10px] md:inline">
            {presetLabel}:
          </span>
          <button
            type="button"
            onClick={() => onPresetChange('default')}
            data-testid="preset-btn-default"
            className={cn(
              'px-2.5 py-1 text-xs transition-all',
              isNeo ? 'rounded' : 'rounded-md',
              preset === 'default'
                ? isNeo
                  ? 'bg-accent border border-black font-bold text-black dark:border-white'
                  : 'bg-foreground text-background font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            Clean
          </button>
          <button
            type="button"
            onClick={() => onPresetChange('neobrutalism')}
            data-testid="preset-btn-neobrutalism"
            className={cn(
              'px-2.5 py-1 text-xs transition-all',
              isNeo ? 'rounded' : 'rounded-md',
              preset === 'neobrutalism'
                ? isNeo
                  ? 'bg-accent border border-black font-bold text-black dark:border-white'
                  : 'bg-foreground text-background font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            Neobrutalism
          </button>
        </div>
      </div>

      {/* Category Filter Pills */}
      <div className="flex flex-wrap items-center gap-1.5 pt-1">
        <CategoryFilterPill
          label={allLabel}
          count={totalCount}
          active={activeCategory === 'all'}
          onClick={() => onCategoryChange('all')}
        />
        {CATEGORIES.map((cat) => (
          <CategoryFilterPill
            key={cat.id}
            label={cat.label}
            count={categoryCounts[cat.id] ?? 0}
            active={activeCategory === cat.id}
            onClick={() => onCategoryChange(cat.id)}
          />
        ))}
      </div>
    </div>
  );
}

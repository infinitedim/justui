'use client';

import React, { useState, useMemo } from 'react';
import type { ComponentMeta } from '@/lib/components-data';
import type { HomepageDictionary } from '@/lib/homepage-translations';
import { CatalogFilterBar } from '@/components/molecules/catalog-filter-bar/catalog-filter-bar';
import { LivingComponentCard } from '@/components/organisms/living-component-card/living-component-card';
import { SearchX } from 'lucide-react';
import { usePreset } from '@/components/providers';

export interface ComponentsCatalogClientProps {
  components: ComponentMeta[];
  lang: string;
  dictionary: HomepageDictionary;
}

export function ComponentsCatalogClient({
  components,
  lang,
  dictionary,
}: ComponentsCatalogClientProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState<string>('all');
  const { preset, setPreset } = usePreset();

  // Compute counts per category
  const categoryCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    for (const c of components) {
      counts[c.category] = (counts[c.category] ?? 0) + 1;
    }
    return counts;
  }, [components]);

  // Client-side instant filter (< 1ms)
  const filteredComponents = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    return components.filter((c) => {
      const matchCategory =
        activeCategory === 'all' || c.category === activeCategory;
      if (!matchCategory) return false;
      if (!query) return true;
      return (
        c.name.toLowerCase().includes(query) ||
        c.slug.toLowerCase().includes(query) ||
        c.description.toLowerCase().includes(query)
      );
    });
  }, [components, activeCategory, searchQuery]);

  const resetFilters = () => {
    setSearchQuery('');
    setActiveCategory('all');
  };

  return (
    <div data-testid="components-catalog-container" className="space-y-8">
      {/* Search and Category Filter Bar */}
      <CatalogFilterBar
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        activeCategory={activeCategory}
        onCategoryChange={setActiveCategory}
        categoryCounts={categoryCounts}
        totalCount={components.length}
        preset={preset}
        onPresetChange={setPreset}
        searchPlaceholder={dictionary.catalogSearchPlaceholder}
        allLabel={dictionary.catalogAllCategories}
        presetLabel={dictionary.catalogPresetLabel}
      />

      {/* Results Count / Info Bar */}
      <div className="text-muted flex items-center justify-between font-mono text-xs">
        <span>
          Showing {filteredComponents.length} of {components.length} components
        </span>
        {searchQuery || activeCategory !== 'all' ? (
          <button
            type="button"
            onClick={resetFilters}
            className="text-accent hover:underline"
          >
            {dictionary.catalogResetFilters}
          </button>
        ) : null}
      </div>

      {/* Grid or Empty State */}
      {filteredComponents.length > 0 ? (
        <div
          data-testid="components-grid"
          className="grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3"
        >
          {filteredComponents.map((component) => (
            <LivingComponentCard
              key={component.slug}
              component={component}
              preset={preset}
              lang={lang}
              copyCliLabel={dictionary.catalogCopyCli}
              viewCodeLabel={dictionary.catalogViewCode}
              docsLabel={dictionary.catalogViewDocs}
            />
          ))}
        </div>
      ) : (
        <div
          data-testid="catalog-empty-state"
          className="border-border flex flex-col items-center justify-center rounded-xl border border-dashed p-12 text-center font-mono"
        >
          <SearchX className="text-muted mb-3 h-8 w-8" />
          <h3 className="text-foreground mb-1 text-sm font-bold">
            {dictionary.catalogNoResults}
          </h3>
          <p className="text-muted mb-4 max-w-sm text-xs">
            Try adjusting your search query or switching to another category.
          </p>
          <button
            type="button"
            onClick={resetFilters}
            className="bg-accent rounded-md px-3 py-1.5 text-xs font-semibold text-[#18181b] transition-opacity hover:opacity-90"
          >
            {dictionary.catalogResetFilters}
          </button>
        </div>
      )}
    </div>
  );
}

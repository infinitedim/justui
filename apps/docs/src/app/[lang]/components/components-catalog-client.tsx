'use client';

import { useState, useMemo } from 'react';
import type { ComponentMeta } from '@/lib/components-data';
import {
  formatMessage,
  type HomepageDictionary,
} from '@/lib/homepage-translations';
import { CatalogFilterBar } from '@/components/molecules/catalog-filter-bar/catalog-filter-bar';
import { LivingComponentCard } from '@/components/organisms/living-component-card/living-component-card';
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
  // The preset is changed in the navbar only; the catalog just follows it.
  const { preset } = usePreset();

  const filteredComponents = useMemo(() => {
    const query = searchQuery.trim().toLowerCase();
    return components.filter((c) => {
      if (activeCategory !== 'all' && c.category !== activeCategory) {
        return false;
      }
      if (!query) return true;
      return (
        c.name.toLowerCase().includes(query) ||
        c.slug.toLowerCase().includes(query) ||
        c.description.toLowerCase().includes(query)
      );
    });
  }, [components, activeCategory, searchQuery]);

  const isFiltering = searchQuery.trim() !== '' || activeCategory !== 'all';

  const resetFilters = () => {
    setSearchQuery('');
    setActiveCategory('all');
  };

  const resetButton = (
    <button
      type="button"
      onClick={resetFilters}
      className="text-accent-text font-medium underline-offset-4 hover:underline"
    >
      {dictionary.catalogResetFilters}
    </button>
  );

  return (
    <div data-testid="components-catalog-container" className="space-y-6">
      <CatalogFilterBar
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        activeCategory={activeCategory}
        onCategoryChange={setActiveCategory}
        searchPlaceholder={dictionary.catalogSearchPlaceholder}
        searchLabel={dictionary.catalogSearchLabel}
        categoryLabel={dictionary.catalogCategoryLabel}
        allLabel={dictionary.catalogAllCategories}
        categoryLabels={dictionary.catalogCategories}
      />

      <div aria-live="polite" className="min-h-5 text-sm">
        {isFiltering && filteredComponents.length > 0 ? (
          <p className="text-secondary flex items-center gap-3">
            <span>
              {formatMessage(dictionary.catalogShowing, {
                shown: filteredComponents.length,
                total: components.length,
              })}
            </span>
            {resetButton}
          </p>
        ) : null}
      </div>

      {filteredComponents.length > 0 ? (
        <div
          data-testid="components-grid"
          className="grid gap-5 md:grid-cols-2 lg:grid-cols-3"
        >
          {filteredComponents.map((component) => (
            <LivingComponentCard
              key={component.slug}
              component={component}
              preset={preset}
              lang={lang}
              categoryLabel={dictionary.catalogCategories[component.category]}
              copyCliLabel={dictionary.catalogCopyCli}
              copiedLabel={dictionary.copied}
              viewCodeLabel={dictionary.catalogViewCode}
              docsLabel={dictionary.catalogViewDocs}
              codeTitle={dictionary.catalogCodeTitle}
              closeLabel={dictionary.catalogCloseCode}
            />
          ))}
        </div>
      ) : (
        <p
          data-testid="catalog-empty-state"
          className="text-secondary py-12 text-center text-sm"
        >
          {formatMessage(dictionary.catalogNoResults, {
            query: searchQuery.trim(),
          })}{' '}
          {resetButton}
        </p>
      )}
    </div>
  );
}

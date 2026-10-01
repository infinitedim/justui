'use client';

import { useMemo, useState } from 'react';
import type { ComponentMeta } from '@/lib/components-data';
import {
  CatalogFilterBar,
  type CategoryFilter,
} from '@/components/molecules/catalog-filter-bar/catalog-filter-bar';
import { LivingComponentCard } from '@/components/organisms/living-component-card/living-component-card';
import { getCatalogDictionary } from '@/lib/catalog-i18n';
import { CatalogI18nProvider } from '@/lib/catalog-i18n/context';
import { accentLink } from '@/lib/ui-classes';

export interface ComponentsCatalogClientProps {
  components: ComponentMeta[];
  lang: string;
}

export function ComponentsCatalogClient({
  components,
  lang,
}: ComponentsCatalogClientProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState<CategoryFilter>('all');
  const { ui, descriptions } = getCatalogDictionary(lang);

  const query = searchQuery.trim();
  const filtering = query.length > 0 || activeCategory !== 'all';

  const filteredComponents = useMemo(() => {
    const needle = query.toLowerCase();
    return components.filter((c) => {
      if (activeCategory !== 'all' && c.category !== activeCategory)
        return false;
      if (!needle) return true;
      return (
        c.name.toLowerCase().includes(needle) ||
        c.slug.includes(needle) ||
        (descriptions[c.slug] ?? '').toLowerCase().includes(needle)
      );
    });
  }, [components, activeCategory, query, descriptions]);

  const resetFilters = () => {
    setSearchQuery('');
    setActiveCategory('all');
  };

  return (
    <CatalogI18nProvider lang={lang}>
      <div data-testid="components-catalog-container" className="space-y-6">
        <CatalogFilterBar
          searchQuery={searchQuery}
          onSearchChange={setSearchQuery}
          activeCategory={activeCategory}
          onCategoryChange={setActiveCategory}
          ui={ui}
        />

        {/* Announced to screen readers; visible only while filtering. */}
        <div
          aria-live="polite"
          className="text-muted flex min-h-5 items-center gap-3 text-sm"
        >
          {filtering && filteredComponents.length > 0 ? (
            <>
              <span data-testid="catalog-result-count">
                {ui.resultCount(filteredComponents.length, components.length)}
              </span>
              <button
                type="button"
                onClick={resetFilters}
                className={accentLink}
              >
                {ui.resetFilters}
              </button>
            </>
          ) : null}
        </div>

        {filteredComponents.length > 0 ? (
          <div
            data-testid="components-grid"
            className="grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3"
          >
            {filteredComponents.map((component) => (
              <LivingComponentCard
                key={component.slug}
                component={component}
                lang={lang}
              />
            ))}
          </div>
        ) : (
          <p
            data-testid="catalog-empty-state"
            className="text-secondary py-12 text-center text-sm"
          >
            {query ? ui.noResults(query) : ui.noResultsInCategory}{' '}
            <button type="button" onClick={resetFilters} className={accentLink}>
              {ui.resetFilters}
            </button>
          </p>
        )}
      </div>
    </CatalogI18nProvider>
  );
}

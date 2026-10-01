'use client';

import { createContext, useContext, useMemo, type ReactNode } from 'react';
import { getCatalogDictionary, type CatalogDictionary } from './index';

const CatalogI18nContext = createContext<CatalogDictionary>(
  getCatalogDictionary('en')
);

/**
 * Provides catalog strings to every preview mock below it, so mocks stay
 * prop-free and the simulator registry does not thread `lang` around.
 */
export function CatalogI18nProvider({
  lang,
  children,
}: {
  lang: string;
  children: ReactNode;
}) {
  const value = useMemo(() => getCatalogDictionary(lang), [lang]);
  
  return (
    <CatalogI18nContext.Provider value={value}>
      {children}
    </CatalogI18nContext.Provider>
  );
}

export function useCatalogI18n(): CatalogDictionary {
  return useContext(CatalogI18nContext);
}
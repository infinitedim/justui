import { crmEn, crmId, type CrmStrings } from './crm';
import {
  descriptionsEn,
  descriptionsId,
  type ComponentDescriptions,
} from './descriptions';
import { catalogUiEn, catalogUiId, type CatalogUiStrings } from './ui';

export type { CrmStrings, CatalogUiStrings, ComponentDescriptions };

export interface CatalogDictionary {
  ui: CatalogUiStrings;
  descriptions: ComponentDescriptions;
  crm: CrmStrings;
}

export const catalogDictionaries: Readonly<
  Record<'en' | 'id', CatalogDictionary>
> = {
  en: { ui: catalogUiEn, descriptions: descriptionsEn, crm: crmEn },
  id: { ui: catalogUiId, descriptions: descriptionsId, crm: crmId },
};

/** Catalog strings for a locale; falls back to English for unknown locales. */
export function getCatalogDictionary(lang: string): CatalogDictionary {
  return lang === 'id' ? catalogDictionaries.id : catalogDictionaries.en;
}

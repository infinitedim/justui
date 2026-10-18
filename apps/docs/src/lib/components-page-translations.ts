import { isLocale, type Locale } from '@/lib/i18n';

/**
 * Copy of the components page (`/[lang]/docs/components`). `{count}` and
 * `{name}` are filled with `formatMessage`; counts come from
 * `src/lib/parts.ts`, never from the copy.
 */
export interface ComponentsPageDictionary {
  metaTitle: string;
  metaDescription: string;
  title: string;
  lead: string;
  copyPart: string;
}

export const componentsPageTranslations = {
  en: {
    metaTitle: 'Components',
    metaDescription:
      'All {count} JustUI parts in runner order. Open one for its docs, or copy the command that adds it to your project.',
    title: 'Every part on the runner',
    lead: '{count} parts. Open one for its docs, or copy its add command.',
    copyPart: 'Copy justui add {name}',
  },
  id: {
    metaTitle: 'Komponen',
    metaDescription:
      'Semua {count} part JustUI sesuai urutan runner. Buka satu untuk dokumentasinya, atau salin perintah untuk menambahkannya ke project kamu.',
    title: 'Semua part di runner',
    lead: '{count} part. Buka satu untuk dokumentasinya, atau salin perintah add-nya.',
    copyPart: 'Salin justui add {name}',
  },
} as const satisfies Record<Locale, ComponentsPageDictionary>;

/** Components page copy for `lang`, English for unknown locales. */
export function getComponentsPageDictionary(
  lang: string
): ComponentsPageDictionary {
  return isLocale(lang)
    ? componentsPageTranslations[lang]
    : componentsPageTranslations.en;
}

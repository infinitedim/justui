import { isLocale, type Locale } from '@/lib/i18n';
import type { PartGroupId } from '@/lib/part-groups';

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
  openDocs: string;
  /** Runner names (landing v3 `ixA`-`ixF`). */
  groups: Record<PartGroupId, string>;
}

export const componentsPageTranslations = {
  en: {
    metaTitle: 'Components',
    metaDescription:
      'All {count} JustUI parts on six runners, live in your preset. Try each one, open its docs, or copy the command that adds it to your project.',
    title: 'Every part on the runner',
    lead: '{count} parts on six runners, drawn in your preset. Each one works: click, drag or type. Select a label to copy its justui add command.',
    copyPart: 'Copy justui add {name}',
    openDocs: 'Open {name} docs',
    groups: {
      actions: 'Actions',
      inputs: 'Inputs',
      navigation: 'Navigation',
      overlays: 'Overlays',
      display: 'Display',
      layout: 'Layout',
    },
  },
  id: {
    metaTitle: 'Komponen',
    metaDescription:
      'Semua {count} part JustUI di enam runner, hidup dengan preset kamu. Coba satu per satu, buka dokumentasinya, atau salin perintah untuk menambahkannya ke project kamu.',
    title: 'Semua part di runner',
    lead: '{count} part di enam runner, digambar dengan preset kamu. Semuanya berfungsi: klik, geser, atau ketik. Pilih label untuk menyalin perintah justui add-nya.',
    copyPart: 'Salin justui add {name}',
    openDocs: 'Buka dokumentasi {name}',
    groups: {
      actions: 'Aksi',
      inputs: 'Input',
      navigation: 'Navigasi',
      overlays: 'Overlay',
      display: 'Tampilan',
      layout: 'Layout',
    },
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

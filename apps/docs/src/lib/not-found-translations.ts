import { isLocale, type Locale } from '@/lib/i18n';

/** 404 copy. `{name}` placeholders are filled with `formatMessage`. */
export interface NotFoundDictionary {
  metaTitle: string;
  description: string;
  title: string;
  /** Stands in for the path before the page knows it (prerender). */
  thisPage: string;
  pathTail: string;
  missing: string;
  runnerNote: string;
  nearestNote: string;
  lookup: string;
  lookupPlaceholder: string;
  home: string;
  docs: string;
  lookupExact: string;
  lookupNear: string;
  lookupNone: string;
}

export const notFoundTranslations = {
  en: {
    metaTitle: 'Part not found',
    description:
      'This page is not part of JustUI. The closest real components are one command away.',
    title: "Part 404 isn't on this runner.",
    thisPage: 'This page',
    pathTail:
      " isn't in the registry. The closest real parts are on the runner above, live in your preset, each one command away.",
    missing: 'missing',
    runnerNote: 'This runner holds parts {first} to {last}.',
    nearestNote: 'Closest matches to the path you asked for.',
    lookup: 'Look up a part',
    lookupPlaceholder: 'e.g. date_picker',
    home: 'Back to home',
    docs: 'Read the docs',
    lookupExact: '{name} is {code} on this runner.',
    lookupNear: 'No part named {query}. Did you mean {best}?',
    lookupNone: 'No part named {query}.',
  },
  id: {
    metaTitle: 'Part tidak ditemukan',
    description:
      'Halaman ini bukan bagian dari JustUI. Komponen asli yang paling mirip cukup satu perintah.',
    title: 'Part 404 tidak ada di runner ini.',
    thisPage: 'Halaman ini',
    pathTail:
      ' tidak ada di registry. Part asli yang paling mirip ada di runner di atas, hidup di preset kamu, masing-masing cukup satu perintah.',
    missing: 'tidak ada',
    runnerNote: 'Runner ini berisi part {first} sampai {last}.',
    nearestNote: 'Paling mirip dengan path yang kamu minta.',
    lookup: 'Cari part',
    lookupPlaceholder: 'mis. date_picker',
    home: 'Kembali ke beranda',
    docs: 'Baca dokumentasi',
    lookupExact: '{name} adalah {code} di runner ini.',
    lookupNear: 'Tidak ada part bernama {query}. Maksudnya {best}?',
    lookupNone: 'Tidak ada part bernama {query}.',
  },
} satisfies Record<Locale, NotFoundDictionary>;

/** 404 dictionary for a locale; unknown values fall back to English. */
export function getNotFoundDictionary(lang: string): NotFoundDictionary {
  return isLocale(lang) ? notFoundTranslations[lang] : notFoundTranslations.en;
}

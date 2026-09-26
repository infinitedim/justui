import { defineI18n } from 'fumadocs-core/i18n';

/** Every locale the site is authored and statically generated in. */
export const locales = ['en', 'id'] as const;

export type Locale = (typeof locales)[number];

export const defaultLocale: Locale = 'en';

export function isLocale(value: string): value is Locale {
  return (locales as readonly string[]).includes(value);
}

/** `generateStaticParams` result shared by every `[lang]` route. */
export function localeStaticParams(): Array<{ lang: Locale }> {
  return locales.map((lang) => ({ lang }));
}

export const i18n = defineI18n({
  defaultLanguage: defaultLocale,
  languages: [...locales],
  parser: 'dir',
});

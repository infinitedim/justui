import type { Route } from 'next';
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

const LOCALE_PREFIX = new RegExp(`^/(${locales.join('|')})(?=/|$)`);

/**
 * Builds a locale-prefixed route such as `/id/docs/guides/migration`.
 *
 * Together with [switchLocalePath], this is the only place where runtime
 * strings are turned into typed `Route`s; every `[lang]` route accepts any
 * locale-prefixed path, so the cast is safe here and nowhere else.
 */
export function localizedHref(lang: string, path: `/${string}` | ''): Route {
  return `/${lang}${path}` as Route;
}

/**
 * Returns [pathname] with its locale segment swapped for [target]. Paths
 * without a locale prefix fall back to the target locale's home page.
 */
export function switchLocalePath(pathname: string, target: Locale): Route {
  if (!LOCALE_PREFIX.test(pathname)) return localizedHref(target, '');
  return localizedHref(
    target,
    pathname.replace(LOCALE_PREFIX, '') as `/${string}` | ''
  );
}

import type { Route } from 'next';
import { defineI18n } from 'fumadocs-core/i18n';

/** Every locale the site is authored and statically generated in. */
export const locales = ['en', 'id'] as const;

export type Locale = (typeof locales)[number];

export const defaultLocale: Locale = 'en';

export function isLocale(value: string): value is Locale {
  return locales.some((loc) => loc === value);
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
  // eslint-disable-next-line @typescript-eslint/consistent-type-assertions -- Next.js typed route constructor
  return `/${lang}${path}` as Route;
}

function isSlashString(str: string): str is `/${string}` {
  return str.startsWith('/');
}

/** The locale a path starts with (`/id/buton` -> `id`), else the default. */
export function localeFromPath(pathname: string): Locale {
  const prefix = LOCALE_PREFIX.exec(pathname)?.[1] ?? '';
  return isLocale(prefix) ? prefix : defaultLocale;
}

/**
 * Returns [pathname] with its locale segment swapped for [target]. Paths
 * without a locale prefix fall back to the target locale's home page.
 */
export function switchLocalePath(pathname: string, target: Locale): Route {
  if (!LOCALE_PREFIX.test(pathname)) return localizedHref(target, '');
  const rawPath = pathname.replace(LOCALE_PREFIX, '');
  const normalizedPath: `/${string}` | '' = isSlashString(rawPath)
    ? rawPath
    : '';
  return localizedHref(target, normalizedPath);
}

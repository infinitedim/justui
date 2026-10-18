import type { Route } from 'next';
import type { Locale } from '@/lib/i18n';

export interface SiteNavProps {
  lang: Locale;
  /** Locale switch targets for the current page. */
  localeHrefs: Record<Locale, Route>;
  /** Hide the search entry (the 404 nav has none). */
  showSearch?: boolean;
  /** Prefetch the locale switch targets (off on the 404: they 404 too). */
  prefetchLocales?: boolean;
}

export interface SiteNavMenuProps {
  lang: Locale;
  showSearch: boolean;
}

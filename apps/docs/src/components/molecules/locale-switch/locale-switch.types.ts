import type { Route } from 'next';
import type { Locale } from '@/lib/i18n';

export interface LocaleSwitchProps {
  /** Current page locale. */
  lang: Locale;
  /** Accessible name of the group. */
  label: string;
  /** Where each locale's button leads. */
  hrefs: Record<Locale, Route>;
  /** Set false when the targets are not real pages (the 404). */
  prefetch?: boolean;
  className?: string;
}

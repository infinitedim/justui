import type { Locale } from '@/lib/i18n';

export interface InstallCommandProps {
  lang: Locale;
  /** `hero`: labelled copy button. `compact`: icon copy button. */
  size?: 'hero' | 'compact';
  className?: string;
}

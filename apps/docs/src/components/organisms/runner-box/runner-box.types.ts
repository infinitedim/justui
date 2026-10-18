import type { ReactNode } from 'react';
import type { KitDictionary } from '@/lib/kit-translations';
import type { Locale } from '@/lib/i18n';

export interface RunnerBoxProps {
  lang: Locale;
  kit: KitDictionary;
  /** Formatted "33 parts" text. */
  partsCount: string;
  landsAs: string;
}

export interface RunnerPartProps {
  slug: string;
  cut: string;
  onCut: (slug: string) => void;
  children: ReactNode;
  className?: string;
}

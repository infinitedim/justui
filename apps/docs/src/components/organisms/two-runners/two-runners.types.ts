import type { ReactNode, RefObject } from 'react';
import type { Locale } from '@/lib/i18n';
import type { KitDictionary } from '@/lib/kit-translations';
import type { JustUIPreset } from '@/lib/presets';

export interface TwoRunnersProps {
  lang: Locale;
}

export interface RunnerColumnProps {
  preset: JustUIPreset;
  /** Text of the chip shown on the visitor's own preset. */
  inHand: string;
  /** The visitor's stored preset. */
  current: JustUIPreset;
  columnRef: RefObject<HTMLDivElement | null>;
  className?: string;
  children: ReactNode;
}

export interface SettingsScreenProps {
  kit: KitDictionary;
}

import type { ReactNode } from 'react';
import type { Locale } from '@/lib/i18n';

export interface FeatureRowsProps {
  lang: Locale;
}

export interface FeatureRowProps {
  title: string;
  body: string;
  /** The last row closes the list with a bottom rule. */
  last?: boolean;
  children: ReactNode;
}

export interface TokenTableProps {
  /** Header of the token-name column. */
  tokenColumn: string;
}

export interface TextWipeProps {
  onPaper: string;
  onInk: string;
  save: string;
  saveDraft: string;
}

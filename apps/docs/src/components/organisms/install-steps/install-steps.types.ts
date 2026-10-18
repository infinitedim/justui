import type { ReactNode } from 'react';
import type { Locale } from '@/lib/i18n';

export interface InstallStepsProps {
  lang: Locale;
}

export interface InstallStepProps {
  number: number;
  title: string;
  children: ReactNode;
}

export interface CommandBoxProps {
  command: string;
  copyLabel: string;
  copyText: string;
  copiedText: string;
}

export interface WrittenFilesProps {
  label: string;
  children: ReactNode;
}

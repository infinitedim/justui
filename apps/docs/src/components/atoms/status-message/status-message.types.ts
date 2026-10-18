import type { ReactNode } from 'react';

/** Spec 5.3 feedback tones: bottle, cognac and oxblood. */
export type StatusTone = 'success' | 'warning' | 'error';

export interface StatusMessageProps {
  tone: StatusTone;
  children: ReactNode;
  className?: string;
}

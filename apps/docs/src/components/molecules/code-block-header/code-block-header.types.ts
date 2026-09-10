import type { ReactNode } from 'react';

export interface CodeBlockHeaderProps {
  /** File name or language label. */
  title: string;
  /** Optional right-side actions (e.g. CopyButton). */
  actions?: ReactNode;
  className?: string;
}

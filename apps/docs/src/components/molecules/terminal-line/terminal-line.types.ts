import type { HTMLAttributes, ReactNode } from 'react';

export type TerminalLineKind =
  'output' | 'info' | 'success' | 'error' | 'warning';

export interface TerminalLineProps extends HTMLAttributes<HTMLDivElement> {
  /** The visual kind of the line which determines its color. */
  kind?: TerminalLineKind;
  /** Optional timestamp prefix. */
  timestamp?: string;
  children?: ReactNode;
}

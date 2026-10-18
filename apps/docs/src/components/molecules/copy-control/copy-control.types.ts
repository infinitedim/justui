import type { ReactNode } from 'react';

export type CopyControlVariant = 'labelled' | 'icon' | 'boxed' | 'row';

export interface CopyControlProps {
  /** Text written to the clipboard. */
  text: string;
  /** Accessible name of the button. */
  label: string;
  /** Visible text (labelled variant) and announced status. */
  copyText: string;
  copiedText: string;
  variant?: CopyControlVariant;
  className?: string;
  /** Row variant only: visible content before the icon. */
  children?: ReactNode;
}

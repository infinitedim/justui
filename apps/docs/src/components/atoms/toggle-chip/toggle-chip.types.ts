import type { ButtonHTMLAttributes, ReactNode } from 'react';

export interface ToggleChipProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** Whether the chip is currently active/selected. */
  active?: boolean;
  children?: ReactNode;
}

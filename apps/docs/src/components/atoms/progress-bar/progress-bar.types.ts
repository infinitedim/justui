import type { HTMLAttributes } from 'react';

export interface ProgressBarProps extends HTMLAttributes<HTMLDivElement> {
  /** Progress value from 0 to 100. */
  value: number;
  /** Maximum value. Default 100. */
  max?: number;
  /** Accessible label. */
  label?: string;
}

import type { InputHTMLAttributes } from 'react';

export interface SliderProps extends Omit<
  InputHTMLAttributes<HTMLInputElement>,
  'type' | 'size'
> {
  /** Current value. */
  value?: number;
  /** Minimum value. Default 0. */
  min?: number;
  /** Maximum value. Default 100. */
  max?: number;
  /** Step increment. Default 1. */
  step?: number;
  /** Accessible label. */
  label?: string;
}

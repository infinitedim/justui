import type { InputHTMLAttributes } from 'react';

export type InputSize = 'sm' | 'md' | 'lg';

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  /** Visual size of the input. */
  inputSize?: InputSize;
  /** Whether to show an error border state. */
  error?: boolean;
}

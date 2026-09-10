import type { HTMLAttributes } from 'react';

export interface FormulaMathBlockProps extends HTMLAttributes<HTMLDivElement> {

  /** LaTeX or plain-text formula string. */
  formula: string;
  /** Optional caption below the formula. */
  caption?: string;
}

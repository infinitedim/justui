import type { ElementType, HTMLAttributes, ReactNode } from 'react';

export type TypographyVariant =
  | 'h1'
  | 'h2'
  | 'h3'
  | 'h4'
  | 'body'
  | 'body-sm'
  | 'caption'
  | 'overline'
  | 'mono';

export type TypographyWeight = 'normal' | 'medium' | 'semibold' | 'bold';

export type TypographyColor =
  | 'primary'
  | 'secondary'
  | 'muted'
  | 'accent'
  | 'error'
  | 'success'
  | 'warning'
  | 'inherit';

export interface TypographyProps extends HTMLAttributes<HTMLElement> {
  /** The visual variant to render. */
  variant?: TypographyVariant;
  /** Override the rendered HTML element tag. */
  as?: ElementType;
  /** Font weight override. */
  weight?: TypographyWeight;
  /** Semantic color token. */
  color?: TypographyColor;
  /** Whether to truncate text with ellipsis. */
  truncate?: boolean;
  children?: ReactNode;
}

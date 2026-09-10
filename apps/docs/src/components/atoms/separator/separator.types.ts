import type { HTMLAttributes } from 'react';

export type SeparatorOrientation = 'horizontal' | 'vertical';

export interface SeparatorProps extends HTMLAttributes<HTMLDivElement> {
  orientation?: SeparatorOrientation;
  /** Whether to render a decorative (non-semantic) separator. Default true. */
  decorative?: boolean;
}

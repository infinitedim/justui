import type { HTMLAttributes } from 'react';

export interface SkeletonBoxProps extends HTMLAttributes<HTMLDivElement> {
  /** Width as a Tailwind class or CSS value. */
  width?: string;
  /** Height as a Tailwind class or CSS value. */
  height?: string;
  /** Render as a circle (equal width/height with full rounding). */
  circle?: boolean;
}

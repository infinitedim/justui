import type { HTMLAttributes } from 'react';

export interface DotGridProps extends HTMLAttributes<HTMLDivElement> {
  /** Number of columns. Default 5. */
  cols?: number;
  /** Number of rows. Default 5. */
  rows?: number;
  /** Gap between dots in pixels. Default 16. */
  gap?: number;
  /** Dot radius in pixels. Default 1.5. */
  dotSize?: number;
}

import type { HTMLAttributes, ReactNode } from 'react';

export type TooltipPosition = 'top' | 'bottom' | 'left' | 'right';

export interface TooltipBubbleProps extends HTMLAttributes<HTMLDivElement> {
  /** Position relative to the anchor element. */
  position?: TooltipPosition;
  /** Whether the tooltip is visible. */
  visible?: boolean;
  children?: ReactNode;
}

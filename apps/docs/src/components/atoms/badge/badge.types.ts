import type { HTMLAttributes, ReactNode } from 'react';

export type BadgeVariant =
  'default' | 'accent' | 'success' | 'warning' | 'error' | 'outline';

export interface BadgeProps extends HTMLAttributes<HTMLSpanElement> {
  variant?: BadgeVariant;
  children?: ReactNode;
}

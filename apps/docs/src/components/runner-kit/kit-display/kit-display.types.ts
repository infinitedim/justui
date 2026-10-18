import type { ReactNode } from 'react';

export interface KitBadgeProps {
  children: ReactNode;
  className?: string;
}

export interface KitAvatarProps {
  /** Up to three characters shown in the circle. */
  initials: string;
  className?: string;
}

export interface KitAvatarGroupProps {
  initials: readonly string[];
  className?: string;
}

export interface KitSeparatorProps {
  start: string;
  end: string;
  className?: string;
}

export interface KitTooltipProps {
  /** Tooltip text; also the icon button's accessible name. */
  label: string;
  className?: string;
}

export interface KitSkeletonProps {
  className?: string;
}

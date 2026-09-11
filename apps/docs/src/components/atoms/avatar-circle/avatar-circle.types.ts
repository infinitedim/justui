import type { ImgHTMLAttributes } from 'react';

export type AvatarSize = 'sm' | 'md' | 'lg' | 'xl';

export interface AvatarCircleProps extends Omit<
  ImgHTMLAttributes<HTMLImageElement>,
  'width' | 'height'
> {
  /** Display size preset. */
  size?: AvatarSize;
  /** Fallback initials when no src is provided. */
  fallback?: string;
}

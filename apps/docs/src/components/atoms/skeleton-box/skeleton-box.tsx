import { cn } from '@/lib/cn';
import type { SkeletonBoxProps } from './skeleton-box.types';

/**
 * Skeleton placeholder atom. Server Component.
 * Renders a pulsing placeholder box for loading states.
 */
export function SkeletonBox({
  width,
  height,
  circle = false,
  className,
  style,
  ...rest
}: SkeletonBoxProps) {
  return (
    <div
      aria-hidden="true"
      className={cn(
        'bg-border animate-pulse',
        circle ? 'rounded-full' : 'rounded-(--just-radius-md)',
        className
      )}
      style={{
        width: width ?? (circle ? height : undefined),
        height,
        ...style,
      }}
      {...rest}
    />
  );
}

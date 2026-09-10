import { cn } from '@/lib/cn';
import type { AvatarCircleProps, AvatarSize } from './avatar-circle.types';

const sizePxMap: Record<AvatarSize, number> = {
  sm: 28,
  md: 36,
  lg: 48,
  xl: 64,
};

const sizeClassMap: Record<AvatarSize, string> = {
  sm: 'h-7 w-7 text-[10px]',
  md: 'h-9 w-9 text-xs',
  lg: 'h-12 w-12 text-sm',
  xl: 'h-16 w-16 text-base',
};

/**
 * Circular avatar atom. Server Component.
 * Renders an image when `src` is provided, otherwise shows initials fallback.
 */
export function AvatarCircle({
  size = 'md',
  fallback,
  src,
  alt = '',
  className,
  ...rest
}: AvatarCircleProps) {
  const base = cn(
    'inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full',
    'border border-[length:var(--just-border-width)] border-border',
    'shadow-[var(--just-shadow-solid)]',
    sizeClassMap[size],
    className,
  );

  if (src) {
    const px = sizePxMap[size];
    return (
      <img
        src={src}
        alt={alt}
        width={px}
        height={px}
        className={cn(base, 'object-cover')}
        {...rest}
      />
    );
  }

  return (
    <span className={cn(base, 'bg-card font-mono font-medium text-muted')} aria-label={alt}>
      {fallback ?? '?'}
    </span>
  );
}

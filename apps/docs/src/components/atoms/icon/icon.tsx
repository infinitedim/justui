import { cn } from '@/lib/cn';
import type { IconProps, IconSize } from './icon.types';

const sizeMap: Record<IconSize, number> = {
  xs: 12,
  sm: 14,
  md: 16,
  lg: 20,
  xl: 24,
};

/**
 * Icon wrapper atom. Server Component.
 * Standardizes lucide-react icon sizing and accessibility attributes.
 */
export function Icon({
  icon: IconComponent,
  size = 'md',
  label,
  className,
  ...rest
}: IconProps) {
  const px = sizeMap[size];

  return (
    <IconComponent
      width={px}
      height={px}
      className={cn('shrink-0', className)}
      role={label ? 'img' : 'presentation'}
      aria-label={label}
      aria-hidden={label ? undefined : true}
      {...rest}
    />
  );
}

import { cn } from '@/lib/cn';
import type { SeparatorProps } from './separator.types';

/**
 * Visual separator atom. Server Component.
 * Renders a horizontal or vertical divider line using the --just-border token.
 */
export function Separator({
  orientation = 'horizontal',
  decorative = true,
  className,
  ...rest
}: SeparatorProps) {
  return (
    <div
      role={decorative ? 'none' : 'separator'}
      aria-orientation={decorative ? undefined : orientation}
      className={cn(
        'bg-border shrink-0',
        orientation === 'horizontal' ? 'h-px w-full' : 'h-full w-px',
        className
      )}
      {...rest}
    />
  );
}

import { cn } from '@/lib/cn';
import type { SpinnerProps, SpinnerSize } from './spinner.types';

const sizeClassMap: Record<SpinnerSize, string> = {
  sm: 'h-4 w-4 border-2',
  md: 'h-5 w-5 border-2',
  lg: 'h-8 w-8 border-[3px]',
};

/**
 * Loading spinner atom. Server Component.
 * Renders a CSS-only spinning border circle.
 */
export function Spinner({
  size = 'md',
  label = 'Loading',
  className,
  ...rest
}: SpinnerProps) {
  return (
    <div
      role="status"
      aria-label={label}
      className={cn(
        'inline-block animate-spin rounded-full border-accent border-t-transparent',
        sizeClassMap[size],
        className,
      )}
      {...rest}
    >
      <span className="sr-only">{label}</span>
    </div>
  );
}

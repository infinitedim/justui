import { cn } from '@/lib/cn';
import type { ProgressBarProps } from './progress-bar.types';

/**
 * Determinate progress bar atom. Server Component.
 * Uses ARIA progressbar role with --just-accent for the fill color.
 */
export function ProgressBar({
  value,
  max = 100,
  label = 'Progress',
  className,
  ...rest
}: ProgressBarProps) {
  const pct = Math.min(100, Math.max(0, (value / max) * 100));

  return (
    <div
      role="progressbar"
      aria-valuenow={value}
      aria-valuemin={0}
      aria-valuemax={max}
      aria-label={label}
      className={cn(
        'bg-border h-2 w-full overflow-hidden rounded-full',
        'border-border border-(length:--just-border-width)',
        className
      )}
      {...rest}
    >
      <div
        className="bg-accent h-full transition-[width] duration-300 ease-out"
        style={{ width: `${pct}%` }}
      />
    </div>
  );
}

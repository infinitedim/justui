import { cn } from '@/lib/cn';
import type { StatCounterProps } from './stat-counter.types';

/**
 * Statistic counter molecule. Server Component.
 * Displays a large numeric value with label, used in hero sections and bento cards.
 */
export function StatCounter({
  value,
  label,
  unit,
  className,
}: StatCounterProps) {
  return (
    <div className={cn('flex flex-col items-center gap-1', className)}>
      <span className="text-foreground font-mono text-2xl font-bold md:text-3xl">
        {value}
        {unit ? (
          <span className="text-muted ml-0.5 text-sm font-normal">{unit}</span>
        ) : null}
      </span>
      <span className="text-muted font-mono text-xs">{label}</span>
    </div>
  );
}

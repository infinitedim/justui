import { cn } from '@/lib/cn';
import { kitFieldLabel } from '@/lib/kit-classes';
import type { KitProgressProps } from './kit-range.types';

/** Determinate progress bar: ink indicator on a control-colored track. */
export function KitProgress({ label, value, className }: KitProgressProps) {
  return (
    <div className={cn('flex w-full flex-col gap-2', className)}>
      <div className="flex justify-between">
        <span className={kitFieldLabel}>{label}</span>
        <span className={cn(kitFieldLabel, 'tabular-nums')}>{value}%</span>
      </div>
      <div
        role="progressbar"
        aria-label={label}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-valuenow={value}
        className="bg-ip-border-control neo:h-3 neo:rounded-none neo:border-[2.5px] neo:border-ip-text-primary neo:bg-ip-surface relative h-2 w-full overflow-hidden rounded-full"
      >
        <div
          className="bg-ip-inverse absolute inset-0 origin-left"
          style={{ transform: `scaleX(${value / 100})` }}
        />
      </div>
    </div>
  );
}

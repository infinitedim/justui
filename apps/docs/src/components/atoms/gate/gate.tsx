import { Scissors } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { GateLinesProps, GateProps } from './gate.types';

const line =
  'bg-ip-border-control h-4 w-[1.5px] transition-transform duration-200 ease-[cubic-bezier(0.16,1,0.3,1)]';

/** The two short lines a part hangs from. */
export function GateLines({ narrow = false }: GateLinesProps) {
  return (
    <div aria-hidden="true" className="flex w-0.5 flex-col">
      <span className={cn(line, 'origin-top', narrow && 'scale-y-[0.45]')} />
      <span className={cn(line, 'origin-bottom', narrow && 'scale-y-[0.45]')} />
    </div>
  );
}

/**
 * The gate a part hangs from on the runner: two short lines and a code
 * label set on the frame. A selected gate narrows to 45% and its label
 * turns ink with scissors.
 */
export function Gate({ code, name, selected, onSelect, className }: GateProps) {
  const label = (
    <>
      {selected ? <Scissors size={13} aria-hidden="true" /> : null}
      <span>{code}</span>
      <span
        className={cn(
          'font-medium',
          selected ? 'text-ip-on-inverse' : 'text-ip-text-secondary'
        )}
      >
        {name}
      </span>
    </>
  );
  const labelClass = cn(
    'mt-[3px] flex h-[26px] items-center gap-1.5 rounded-[6px] px-2 text-xs font-bold whitespace-nowrap transition-colors duration-150',
    selected
      ? 'bg-ip-inverse text-ip-on-inverse'
      : 'text-ip-text-primary bg-transparent'
  );
  return (
    <div className={cn('flex items-start gap-2', className)}>
      <GateLines narrow={selected} />
      {onSelect ? (
        <button
          type="button"
          aria-pressed={selected}
          onClick={onSelect}
          className={cn(labelClass, 'cursor-pointer')}
        >
          {label}
        </button>
      ) : (
        <span className={labelClass}>{label}</span>
      )}
    </div>
  );
}

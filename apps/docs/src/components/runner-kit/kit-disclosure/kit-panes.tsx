import { cn } from '@/lib/cn';
import type {
  KitResizableProps,
  KitScrollAreaProps,
} from './kit-disclosure.types';

const controlBox =
  'bg-ip-surface rounded-(--ip-radius-control) border-(length:--ip-line) border-(--ip-part-control-border)';

/** Scroll area with a custom track and a thumb at the top. */
export function KitScrollArea({ lines, className }: KitScrollAreaProps) {
  return (
    <div
      className={cn(
        controlBox,
        'text-ip-text-secondary relative w-[210px] py-2 pr-[22px] pl-3 font-mono text-xs leading-[22px]',
        className
      )}
    >
      {lines.map((line) => (
        <div key={line}>{line}</div>
      ))}
      <span
        aria-hidden="true"
        className="bg-ip-sunken neo:rounded-none absolute inset-y-1.5 right-1.5 w-1.5 rounded-full"
      >
        <span className="bg-ip-border-control neo:bg-ip-text-primary neo:rounded-none absolute top-0 left-0 h-[45%] w-1.5 rounded-full" />
      </span>
    </div>
  );
}

/** Two panes split by a handle with a grip. */
export function KitResizable({ start, end, className }: KitResizableProps) {
  return (
    <div
      className={cn(
        controlBox,
        'text-ip-text-secondary flex h-[72px] w-[220px] overflow-hidden text-xs font-semibold',
        className
      )}
    >
      <div className="bg-ip-surface flex flex-[0_0_40%] items-center justify-center">
        {start}
      </div>
      <div
        aria-hidden="true"
        className="relative w-(--ip-line) bg-(--ip-part-control-border)"
      >
        <span
          className={cn(
            controlBox,
            'neo:rounded-none absolute top-1/2 left-1/2 h-5 w-2 -translate-1/2 rounded-[4px]'
          )}
        />
      </div>
      <div className="bg-ip-sunken flex flex-1 items-center justify-center">
        {end}
      </div>
    </div>
  );
}

import { Check } from 'lucide-react';
import { cn } from '@/lib/cn';
import { kitLabel } from '@/lib/kit-classes';
import type {
  KitCheckboxProps,
  KitRadioGroupProps,
  KitSwitchProps,
} from './kit-selection.types';

const focusRing =
  'peer-focus-visible:outline-(length:--ip-focus-width) peer-focus-visible:outline-offset-2 peer-focus-visible:outline-ip-text-primary peer-focus-visible:outline-solid';

/**
 * Native checkbox with `role="switch"`. Default: borderless pill, thumb on
 * canvas. Neobrutalism: 2.5px ink track, square-feel thumb inset.
 */
export function KitSwitch({
  label,
  defaultChecked,
  hideLabel,
  className,
}: KitSwitchProps) {
  return (
    <label
      className={cn(
        'relative inline-flex cursor-pointer items-center gap-2.5',
        className
      )}
    >
      <input
        type="checkbox"
        role="switch"
        defaultChecked={defaultChecked}
        className="peer sr-only"
      />
      <span
        aria-hidden="true"
        className={cn(
          'bg-ip-border-control peer-checked:bg-ip-inverse block h-5.5 w-10 shrink-0 rounded-full',
          'neo:bg-ip-surface neo:peer-checked:bg-ip-inverse neo:h-6.5 neo:w-11.5 neo:border-[2.5px] neo:border-ip-text-primary',
          focusRing
        )}
      />
      <span
        aria-hidden="true"
        className={cn(
          'bg-ip-canvas absolute top-0.5 left-0.5 size-4.5 rounded-full shadow-(--ip-shadow-thumb) transition-transform duration-150 ease-[cubic-bezier(0.16,1,0.3,1)] peer-checked:translate-x-4.5',
          'neo:bg-ip-text-primary neo:peer-checked:bg-ip-on-inverse neo:top-[5.5px] neo:left-[5.5px] neo:size-3.75 neo:shadow-none neo:peer-checked:translate-x-5'
        )}
      />
      <span className={hideLabel ? 'sr-only' : kitLabel}>{label}</span>
    </label>
  );
}

/** Native checkbox with an ink fill and an on-inverse check when checked. */
export function KitCheckbox({
  label,
  defaultChecked,
  hideLabel,
  className,
}: KitCheckboxProps) {
  return (
    <label
      className={cn(
        'inline-flex cursor-pointer items-center gap-2.5',
        className
      )}
    >
      <input
        type="checkbox"
        defaultChecked={defaultChecked}
        className="peer sr-only"
      />
      <span
        aria-hidden="true"
        className={cn(
          'bg-ip-surface text-ip-on-inverse peer-checked:border-ip-inverse peer-checked:bg-ip-inverse flex size-4.5 shrink-0 items-center justify-center rounded-[4px] border-(length:--ip-line) border-(--ip-part-control-border) [&>svg]:invisible peer-checked:[&>svg]:visible',
          'neo:size-5.5 neo:rounded-none',
          focusRing
        )}
      >
        <Check size={14} strokeWidth={3} />
      </span>
      <span className={hideLabel ? 'sr-only' : kitLabel}>{label}</span>
    </label>
  );
}

/** Native radio group: arrow keys move between options for free. */
export function KitRadioGroup({
  label,
  name,
  options,
  defaultIndex = 0,
  className,
}: KitRadioGroupProps) {
  return (
    <div
      role="radiogroup"
      aria-label={label}
      className={cn('flex flex-col gap-2.5', className)}
    >
      {options.map((option, index) => (
        <label
          key={option}
          className="inline-flex cursor-pointer items-center gap-2.5"
        >
          <input
            type="radio"
            name={name}
            defaultChecked={index === defaultIndex}
            className="peer sr-only"
          />
          <span
            aria-hidden="true"
            className={cn(
              'bg-ip-surface peer-checked:border-ip-inverse flex size-4.5 shrink-0 items-center justify-center rounded-full border-(length:--ip-line) border-(--ip-part-control-border) [&>span]:scale-0 peer-checked:[&>span]:scale-100',
              'neo:size-5.5 neo:peer-checked:border-ip-text-primary',
              focusRing
            )}
          >
            <span className="bg-ip-inverse neo:size-2.5 size-2 rounded-full transition-transform duration-150" />
          </span>
          <span className={kitLabel}>{option}</span>
        </label>
      ))}
    </div>
  );
}

'use client';

// Client leaf: the visible percentage and the track fill follow the value.
import { useId, useState } from 'react';
import { cn } from '@/lib/cn';
import { kitFieldLabel } from '@/lib/kit-classes';
import type { KitSliderProps } from './kit-range.types';

/** Native range input styled by `.ip-range` in globals.css. */
export function KitSlider({
  label,
  defaultValue = 60,
  className,
}: KitSliderProps) {
  const id = useId();
  const [value, setValue] = useState(defaultValue);
  return (
    <div className={cn('flex w-full flex-col gap-2', className)}>
      <div className="flex justify-between">
        <label htmlFor={id} className={kitFieldLabel}>
          {label}
        </label>
        <span className={cn(kitFieldLabel, 'tabular-nums')} aria-hidden="true">
          {value}%
        </span>
      </div>
      <input
        id={id}
        type="range"
        min={0}
        max={100}
        value={value}
        aria-valuetext={`${value}%`}
        onChange={(event) => setValue(Number(event.target.value))}
        className="ip-range"
        style={{ '--ip-range-value': `${value}%` }}
      />
    </div>
  );
}

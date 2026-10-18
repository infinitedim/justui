'use client';

// Client leaf: the date pickers keep the selected day or range.
import { useState } from 'react';
import { cn } from '@/lib/cn';
import { kitFieldLabel } from '@/lib/kit-classes';
import type { KitDatePickerProps } from './kit-data.types';

const DAYS = [14, 15, 16, 17, 18, 19, 20] as const;

const dayBase =
  'neo:size-8 neo:rounded-none flex size-[30px] cursor-pointer items-center justify-center rounded-full border-[2.5px] border-transparent p-0 text-[13px] tabular-nums';

const daySelected =
  'bg-ip-inverse text-ip-on-inverse neo:border-ip-text-primary font-bold';

/** One week of days; one selected day in ink. */
export function KitDatePicker({ month, label, className }: KitDatePickerProps) {
  const [selected, setSelected] = useState<number>(17);
  return (
    <div className={cn('flex flex-col gap-2', className)}>
      <span className={kitFieldLabel}>{month}</span>
      <div role="group" aria-label={label} className="flex gap-0.5">
        {DAYS.map((day) => (
          <button
            key={day}
            type="button"
            aria-pressed={day === selected}
            onClick={() => setSelected(day)}
            className={cn(
              dayBase,
              day === selected
                ? daySelected
                : 'text-ip-text-primary hover:bg-ip-hover font-medium'
            )}
          >
            {day}
          </button>
        ))}
      </div>
    </div>
  );
}

/** A three-day range: ink ends, hover-fill middle (spec P4 date range). */
export function KitDateRangePicker({
  month,
  label,
  className,
}: KitDatePickerProps) {
  const [start, setStart] = useState<number>(16);
  const end = Math.min(start + 2, DAYS.at(-1) ?? start);
  return (
    <div className={cn('flex flex-col gap-2', className)}>
      <span className={kitFieldLabel}>{month}</span>
      <div role="group" aria-label={label} className="flex gap-0.5">
        {DAYS.map((day) => {
          const isEnd = day === start || day === end;
          const inside = day > start && day < end;
          return (
            <button
              key={day}
              type="button"
              aria-pressed={day >= start && day <= end}
              onClick={() => setStart(day)}
              className={cn(
                dayBase,
                isEnd && daySelected,
                inside && 'bg-ip-hover text-ip-text-primary font-semibold',
                !isEnd && !inside && 'text-ip-text-primary font-medium'
              )}
            >
              {day}
            </button>
          );
        })}
      </div>
    </div>
  );
}

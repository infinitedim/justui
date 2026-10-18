import { cn } from '@/lib/cn';
import { kitCardTitle } from '@/lib/kit-classes';
import type { KitTableProps, KitTimePickerProps } from './kit-data.types';

const cell = 'px-2.5 py-[7px] text-left';
const rule =
  'border-b-(length:--ip-separator-width) border-(--ip-part-separator)';

/** Two-column data table with a sunken header row. */
export function KitTable({ columns, rows, className }: KitTableProps) {
  return (
    <table
      className={cn(
        'text-ip-text-primary w-full max-w-62.5 border-collapse border-(length:--ip-line) border-(--ip-part-container-border) text-[13px]',
        className
      )}
    >
      <thead>
        <tr>
          {columns.map((column) => (
            <th
              key={column}
              scope="col"
              className={cn(
                cell,
                rule,
                'bg-ip-sunken text-ip-text-secondary font-semibold'
              )}
            >
              {column}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {rows.map((row, index) => (
          <tr key={row[0]}>
            {row.map((value) => (
              <td
                key={value}
                className={cn(
                  cell,
                  index < rows.length - 1 && rule,
                  'font-mono text-xs'
                )}
              >
                {value}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

/** Hours and minutes in two sunken cells. */
export function KitTimePicker({
  hours,
  minutes,
  className,
}: KitTimePickerProps) {
  const timeCell =
    'bg-ip-sunken text-ip-text-primary flex h-11 w-14 items-center justify-center rounded-[8px] border-(length:--ip-line) border-(--ip-part-control-border) text-[22px] font-bold tabular-nums neo:h-12 neo:rounded-none';
  return (
    <div className={cn('flex items-center gap-2', className)}>
      <span className={timeCell}>{hours}</span>
      <span aria-hidden="true" className={kitCardTitle}>
        :
      </span>
      <span className={timeCell}>{minutes}</span>
    </div>
  );
}

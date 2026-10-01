'use client';

import { useId } from 'react';
import { CalendarRange } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function DateRangePickerMock() {
  const { crm } = useCatalogI18n();
  const labelId = useId();

  return (
    <div className="w-full max-w-60 space-y-1.5">
      <p id={labelId} className="text-foreground text-xs font-medium">
        {crm.dateRangePicker.label}
      </p>
      <div
        role="group"
        aria-labelledby={labelId}
        data-testid="mock-date-range-picker"
        className={cn(
          surface,
          'text-foreground flex h-9 items-center gap-2 px-3 text-sm'
        )}
      >
        <CalendarRange
          className="text-muted h-4 w-4 shrink-0"
          aria-hidden="true"
        />
        <span className="flex-1">{crm.dateRangePicker.value}</span>
        <span className="text-muted text-xs">{crm.dateRangePicker.days}</span>
      </div>
    </div>
  );
}

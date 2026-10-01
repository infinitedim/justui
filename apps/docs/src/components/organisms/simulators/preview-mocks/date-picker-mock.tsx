'use client';

import { useId } from 'react';
import { Calendar } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function DatePickerMock() {
  const { crm } = useCatalogI18n();
  const labelId = useId();

  return (
    <div className="w-full max-w-56 space-y-1.5">
      <p id={labelId} className="text-foreground text-xs font-medium">
        {crm.datePicker.label}
      </p>
      <div
        role="group"
        aria-labelledby={labelId}
        data-testid="mock-date-picker"
        className={cn(
          surface,
          'text-foreground flex h-9 items-center gap-2 px-3 text-sm'
        )}
      >
        <Calendar className="text-muted h-4 w-4" aria-hidden="true" />
        <time dateTime="2026-09-17">{crm.datePicker.value}</time>
      </div>
    </div>
  );
}

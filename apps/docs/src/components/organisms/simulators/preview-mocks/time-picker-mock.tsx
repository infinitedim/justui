'use client';

import { useId, useState } from 'react';
import { Clock } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { neutralControl, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const HOURS = 14;
const MINUTES = 30;

/** Toggles between JustTimeFormat.twentyFourHour and .twelveHour. */
export function TimePickerMock() {
  const { crm } = useCatalogI18n();
  const [twelveHour, setTwelveHour] = useState(false);
  const labelId = useId();

  const minutes = String(MINUTES).padStart(2, '0');
  const time = twelveHour
    ? `${HOURS % 12 || 12}:${minutes} ${HOURS < 12 ? 'AM' : 'PM'}`
    : `${HOURS}:${minutes}`;

  return (
    <div className="w-full max-w-56 space-y-1.5">
      <p id={labelId} className="text-foreground text-xs font-medium">
        {crm.timePicker.label}
      </p>
      <div className="flex items-center gap-2">
        <div
          role="group"
          aria-labelledby={labelId}
          data-testid="mock-time-picker"
          className={cn(
            surface,
            'text-foreground flex h-9 flex-1 items-center gap-2 px-3 text-sm tabular-nums'
          )}
        >
          <Clock className="text-muted h-4 w-4" aria-hidden="true" />
          <time dateTime={`${HOURS}:${minutes}`}>{time}</time>
        </div>
        <button
          type="button"
          onClick={() => setTwelveHour((t) => !t)}
          aria-pressed={twelveHour}
          className={cn(neutralControl, 'h-9 px-2.5 font-mono text-xs')}
        >
          {twelveHour ? '12h' : '24h'}
        </button>
      </div>
    </div>
  );
}

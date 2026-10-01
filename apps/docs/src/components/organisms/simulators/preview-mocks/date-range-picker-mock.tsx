'use client';

import { CalendarRange } from 'lucide-react';
import { cn } from '@/lib/cn';
import { hint, label, surface } from './mock-styles';

export function DateRangePickerMock() {
  return (
    <div className="w-full max-w-56 space-y-1.5">
      <span className={cn(label, 'block')}>Sales report</span>
      <div
        data-testid="mock-date-range-picker"
        className={cn(surface, 'flex h-9 items-center gap-2 px-3 text-sm')}
      >
        <CalendarRange
          className="text-muted h-4 w-4 shrink-0"
          aria-hidden="true"
        />
        <span>1 Oct - 15 Oct 2026</span>
      </div>
      <p className={hint}>15 days, 212 orders</p>
    </div>
  );
}

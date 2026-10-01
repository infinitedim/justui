'use client';

import { Calendar } from 'lucide-react';
import { cn } from '@/lib/cn';
import { label, surface } from './mock-styles';

export function DatePickerMock() {
  return (
    <div className="w-full max-w-52 space-y-1.5">
      <span className={cn(label, 'block')}>Delivery date</span>
      <div
        data-testid="mock-date-picker"
        className={cn(surface, 'flex h-9 items-center gap-2 px-3 text-sm')}
      >
        <Calendar className="text-muted h-4 w-4" aria-hidden="true" />
        <span>Fri, 13 Nov 2026</span>
      </div>
    </div>
  );
}

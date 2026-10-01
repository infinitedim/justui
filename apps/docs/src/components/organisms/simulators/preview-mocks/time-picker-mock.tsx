'use client';

import { useState } from 'react';
import { Clock } from 'lucide-react';
import { cn } from '@/lib/cn';
import { label, surface } from './mock-styles';

export function TimePickerMock() {
  const [period, setPeriod] = useState<'AM' | 'PM'>('PM');

  return (
    <div className="space-y-1.5">
      <span className={cn(label, 'block')}>Pickup time</span>
      <div
        data-testid="mock-time-picker"
        className={cn(
          surface,
          'inline-flex h-9 items-center gap-2 pr-1 pl-3 text-sm'
        )}
      >
        <Clock className="text-muted h-4 w-4" aria-hidden="true" />
        <span>06:30</span>
        <button
          type="button"
          onClick={() => setPeriod((p) => (p === 'AM' ? 'PM' : 'AM'))}
          aria-label={`Switch to ${period === 'AM' ? 'PM' : 'AM'}`}
          className="bg-fill text-foreground rounded-(--just-radius-sm) px-2 py-0.5 text-xs font-medium"
        >
          {period}
        </button>
      </div>
    </div>
  );
}

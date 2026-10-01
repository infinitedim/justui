'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { hint, outlineButton, raised } from './mock-styles';

export function CardMock() {
  const [tracking, setTracking] = useState(false);

  return (
    <div data-testid="mock-card" className={cn(raised, 'w-full max-w-56 p-4')}>
      <div className="flex items-baseline justify-between gap-2">
        <span className="text-sm font-semibold">Order #1042</span>
        <span className="text-sm">$48.00</span>
      </div>
      <p className={cn(hint, 'mt-1')}>2 items, arriving Friday</p>
      <button
        type="button"
        onClick={() => setTracking((t) => !t)}
        className={cn(outlineButton, 'mt-3 h-8 px-3 text-xs')}
      >
        {tracking ? 'In transit: Jakarta hub' : 'Track parcel'}
      </button>
    </div>
  );
}

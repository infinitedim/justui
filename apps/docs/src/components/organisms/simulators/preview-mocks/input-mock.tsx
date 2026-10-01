'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { label, surface } from './mock-styles';

export function InputMock() {
  const [value, setValue] = useState('Leave it at the front desk');

  return (
    <div className="w-full max-w-60 space-y-1.5">
      <label htmlFor="mock-delivery-note" className={cn(label, 'block')}>
        Delivery note
      </label>
      <input
        id="mock-delivery-note"
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        data-testid="mock-input"
        className={cn(
          surface,
          'h-9 w-full px-3 text-sm outline-none',
          'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-1'
        )}
      />
    </div>
  );
}

'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { focusRing } from './mock-styles';

const options = [
  { id: 'standard', label: 'Standard delivery' },
  { id: 'express', label: 'Express delivery' },
];

export function RadioMock() {
  const [selected, setSelected] = useState('standard');

  return (
    <div
      role="radiogroup"
      aria-label="Delivery speed"
      data-testid="mock-radio"
      className="space-y-2.5"
    >
      {options.map((opt) => {
        const checked = selected === opt.id;
        return (
          <button
            key={opt.id}
            type="button"
            role="radio"
            aria-checked={checked}
            onClick={() => setSelected(opt.id)}
            data-testid={`mock-radio-${opt.id}`}
            className={cn('flex items-center gap-2.5', focusRing)}
          >
            <span className="bg-card border-border flex h-5 w-5 items-center justify-center rounded-full border-(length:--just-border-width)">
              {checked ? (
                <span className="bg-foreground h-2.5 w-2.5 rounded-full" />
              ) : null}
            </span>
            <span className="text-foreground text-sm">{opt.label}</span>
          </button>
        );
      })}
    </div>
  );
}

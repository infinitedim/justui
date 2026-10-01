'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { focusRing } from './mock-styles';

const methods = [
  { id: 'card', name: 'Card' },
  { id: 'transfer', name: 'Bank transfer' },
  { id: 'cod', name: 'Pay on delivery' },
];

export function RadioGroupMock() {
  const [selected, setSelected] = useState('card');

  return (
    <div
      role="radiogroup"
      aria-label="Payment method"
      data-testid="mock-radio-group"
      className="w-full max-w-56 space-y-1.5"
    >
      {methods.map((m) => {
        const checked = selected === m.id;
        return (
          <button
            key={m.id}
            type="button"
            role="radio"
            aria-checked={checked}
            onClick={() => setSelected(m.id)}
            data-testid={`mock-radio-group-${m.id}`}
            className={cn(
              'border-border flex w-full items-center justify-between rounded-(--just-radius-md) border-(length:--just-border-width) px-3 py-2 text-sm',
              checked ? 'bg-accent-muted font-medium' : 'bg-card',
              focusRing
            )}
          >
            <span className="text-foreground">{m.name}</span>
            <span className="bg-card border-border flex h-4 w-4 items-center justify-center rounded-full border-(length:--just-border-width)">
              {checked ? (
                <span className="bg-foreground h-2 w-2 rounded-full" />
              ) : null}
            </span>
          </button>
        );
      })}
    </div>
  );
}

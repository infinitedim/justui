'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { surface } from './mock-styles';

const filters = [
  { id: 'paid', label: 'Paid' },
  { id: 'shipped', label: 'Shipped' },
  { id: 'refunded', label: 'Refunded' },
];

export function ToggleMock() {
  const [active, setActive] = useState<string[]>(['paid']);

  const toggle = (id: string) =>
    setActive((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );

  return (
    <div
      data-testid="mock-toggle"
      role="group"
      aria-label="Filter orders"
      className={cn(surface, 'inline-flex gap-1 p-1')}
    >
      {filters.map(({ id, label }) => {
        const pressed = active.includes(id);
        return (
          <button
            key={id}
            type="button"
            aria-pressed={pressed}
            onClick={() => toggle(id)}
            data-testid={`mock-toggle-${id}`}
            className={cn(
              'h-8 rounded-(--just-radius-sm) px-3 text-sm',
              pressed
                ? 'bg-accent text-accent-foreground font-medium'
                : 'text-secondary hover:text-foreground'
            )}
          >
            {label}
          </button>
        );
      })}
    </div>
  );
}

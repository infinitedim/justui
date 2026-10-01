'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';

const tabs = [
  { id: 'details', label: 'Details' },
  { id: 'shipping', label: 'Shipping' },
  { id: 'invoice', label: 'Invoice' },
];

export function TabsMock() {
  const [active, setActive] = useState('details');

  return (
    <div
      role="tablist"
      aria-label="Order"
      data-testid="mock-tabs"
      className="border-border flex gap-4 border-b border-b-(length:--just-border-width)"
    >
      {tabs.map((t) => {
        const selected = active === t.id;
        return (
          <button
            key={t.id}
            type="button"
            role="tab"
            aria-selected={selected}
            onClick={() => setActive(t.id)}
            data-testid={`mock-tab-${t.id}`}
            className={cn(
              '-mb-(--just-border-width) border-b-2 pb-2 text-sm',
              selected
                ? 'border-foreground text-foreground font-medium'
                : 'text-secondary hover:text-foreground border-transparent'
            )}
          >
            {t.label}
          </button>
        );
      })}
    </div>
  );
}

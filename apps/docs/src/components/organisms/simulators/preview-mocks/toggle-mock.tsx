'use client';

import { useState } from 'react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { neutralControl } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const FILTERS = ['mine', 'overdue', 'starred'] as const;
type Filter = (typeof FILTERS)[number];

export function ToggleMock() {
  const { crm } = useCatalogI18n();
  const [active, setActive] = useState<ReadonlySet<Filter>>(
    () => new Set<Filter>(['mine'])
  );

  const toggle = (id: Filter) => {
    setActive((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  return (
    <div
      role="group"
      aria-label={crm.toggle.label}
      data-testid="mock-toggle"
      className="flex gap-1.5"
    >
      {FILTERS.map((id) => {
        const pressed = active.has(id);
        return (
          <button
            key={id}
            type="button"
            aria-pressed={pressed}
            onClick={() => toggle(id)}
            data-testid={`mock-toggle-${id}`}
            className={cn(
              neutralControl,
              'h-8 px-3 text-xs font-medium',
              pressed ? 'bg-accent text-accent-foreground' : 'text-muted'
            )}
          >
            {crm.toggle[id]}
          </button>
        );
      })}
    </div>
  );
}

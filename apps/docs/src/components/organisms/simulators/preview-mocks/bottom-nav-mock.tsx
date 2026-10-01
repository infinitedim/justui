'use client';

import { useState } from 'react';
import { Layers, ListChecks, Users } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const ICONS = { pipeline: Layers, contacts: Users, tasks: ListChecks } as const;

export function BottomNavMock() {
  const { crm } = useCatalogI18n();
  const [active, setActive] = useState('pipeline');

  return (
    <nav
      aria-label={crm.bottomNav.label}
      data-testid="mock-bottom-nav"
      className={cn(surface, 'flex w-full max-w-64 justify-around px-1 py-1.5')}
    >
      {crm.bottomNav.items.map((item) => {
        const Icon = ICONS[item.id as keyof typeof ICONS] ?? Layers;
        const current = item.id === active;
        return (
          <button
            key={item.id}
            type="button"
            onClick={() => setActive(item.id)}
            aria-current={current ? 'page' : undefined}
            className={cn(
              focusRing,
              'flex min-w-16 flex-col items-center gap-0.5 rounded-(--just-radius-sm) px-2 py-1 text-xs',
              current
                ? 'text-accent-text font-semibold'
                : 'text-muted hover:text-foreground'
            )}
          >
            <Icon className="h-4 w-4" aria-hidden="true" />
            {item.label}
          </button>
        );
      })}
    </nav>
  );
}

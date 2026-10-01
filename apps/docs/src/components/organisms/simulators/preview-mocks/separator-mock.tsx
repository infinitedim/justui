'use client';

import { useCatalogI18n } from '@/lib/catalog-i18n/context';

const COUNTS = { open: 12, won: 7, lost: 3 } as const;

export function SeparatorMock() {
  const { crm } = useCatalogI18n();
  const stats = [
    { id: 'open', label: crm.separator.open, value: COUNTS.open },
    { id: 'won', label: crm.separator.won, value: COUNTS.won },
    { id: 'lost', label: crm.separator.lost, value: COUNTS.lost },
  ] as const;

  return (
    <div data-testid="mock-separator" className="flex items-stretch gap-4">
      {stats.map((stat, index) => (
        <div key={stat.id} className="flex items-stretch gap-4">
          {index > 0 ? (
            <div
              role="separator"
              aria-orientation="vertical"
              className="bg-border w-(--just-border-width)"
            />
          ) : null}
          <div className="flex flex-col items-center">
            <span className="text-foreground text-xl font-semibold tabular-nums">
              {stat.value}
            </span>
            <span className="text-muted text-xs">{stat.label}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

'use client';

import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { raised } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function CardMock() {
  const { crm } = useCatalogI18n();

  return (
    <div
      data-testid="mock-card"
      className={cn(raised, 'w-full max-w-64 p-3.5')}
    >
      <header className="flex items-start justify-between gap-2">
        <h4 className="text-foreground text-sm font-semibold">
          {crm.card.company}
        </h4>
        <span className="bg-warning/15 border-warning/40 text-foreground rounded-(--just-radius-sm) border-(length:--just-border-width) px-1.5 py-0.5 text-xs">
          {crm.stages.proposal}
        </span>
      </header>
      <p className="text-foreground mt-1 text-base font-semibold tabular-nums">
        {crm.card.value}
      </p>
      <footer className="border-border text-muted mt-2.5 flex flex-col gap-0.5 border-t border-t-(length:--just-border-width) pt-2 text-xs">
        <span>{crm.card.owner}</span>
        <span>{crm.card.due}</span>
      </footer>
    </div>
  );
}

'use client';

import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { cn } from '@/lib/cn';

/** Soft badge per deal stage; the dot carries the stage color, the label stays readable. */
const STAGES = [
  { id: 'lead', tone: 'bg-info/15 border-info/40', dot: 'bg-info' },
  {
    id: 'qualified',
    tone: 'bg-warning/15 border-warning/40',
    dot: 'bg-warning',
  },
  { id: 'won', tone: 'bg-success/15 border-success/40', dot: 'bg-success' },
] as const;

export function BadgeMock() {
  const { crm } = useCatalogI18n();

  return (
    <ul className="flex flex-wrap items-center justify-center gap-2">
      {STAGES.map((stage, idx) => (
        <li
          key={stage.id}
          data-testid={`mock-badge-${idx}`}
          className={cn(
            'text-foreground inline-flex items-center gap-1.5 rounded-(--just-radius-sm) border-(length:--just-border-width) px-2 py-0.5 text-xs font-medium',
            stage.tone
          )}
        >
          <span
            className={cn('h-1.5 w-1.5 rounded-full', stage.dot)}
            aria-hidden="true"
          />
          {crm.stages[stage.id]}
        </li>
      ))}
    </ul>
  );
}

'use client';

import { useId, useState, type KeyboardEvent } from 'react';
import { Check, ChevronDown } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing, raised, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const STAGE_IDS = ['lead', 'qualified', 'proposal', 'won'] as const;
type StageId = (typeof STAGE_IDS)[number];

export function SelectMock() {
  const { crm } = useCatalogI18n();
  const [selected, setSelected] = useState<StageId>('qualified');
  const [open, setOpen] = useState(false);
  const labelId = useId();
  const listId = useId();

  const choose = (id: StageId) => {
    setSelected(id);
    setOpen(false);
  };

  const onKeyDown = (event: KeyboardEvent<HTMLElement>) => {
    if (event.key === 'Escape') setOpen(false);
  };

  return (
    <div className="relative w-full max-w-50" onKeyDown={onKeyDown}>
      <p id={labelId} className="text-foreground mb-1.5 text-xs font-medium">
        {crm.select.label}
      </p>
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-controls={open ? listId : undefined}
        aria-labelledby={labelId}
        data-testid="mock-select-trigger"
        className={cn(
          surface,
          focusRing,
          'text-foreground flex h-9 w-full items-center justify-between px-3 text-sm'
        )}
      >
        <span>{crm.stages[selected]}</span>
        <ChevronDown
          className={cn('h-4 w-4 transition-transform', open && 'rotate-180')}
          aria-hidden="true"
        />
      </button>

      {open ? (
        <ul
          id={listId}
          role="listbox"
          aria-labelledby={labelId}
          data-testid="mock-select-menu"
          className={cn(
            raised,
            'absolute top-full left-0 z-20 mt-1.5 w-full py-1 text-sm'
          )}
        >
          {STAGE_IDS.map((id) => (
            <li key={id} role="option" aria-selected={selected === id}>
              <button
                type="button"
                onClick={() => choose(id)}
                className="hover:bg-accent-muted text-foreground flex w-full items-center justify-between px-3 py-1.5 text-left"
              >
                {crm.stages[id]}
                {selected === id ? (
                  <Check
                    className="text-accent-text h-4 w-4"
                    aria-hidden="true"
                  />
                ) : null}
              </button>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  );
}

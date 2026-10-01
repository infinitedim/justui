'use client';

import { useId, useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function AccordionMock() {
  const { crm } = useCatalogI18n();
  const [openIndex, setOpenIndex] = useState<number | null>(null);
  const baseId = useId();

  return (
    <div
      data-testid="mock-accordion"
      className={cn(surface, 'divide-border w-full max-w-64 divide-y text-sm')}
    >
      {crm.accordion.items.map((item, index) => {
        const open = openIndex === index;
        const panelId = `${baseId}-panel-${index}`;
        return (
          <div key={item.title}>
            <button
              type="button"
              onClick={() => setOpenIndex(open ? null : index)}
              aria-expanded={open}
              aria-controls={panelId}
              className={cn(
                focusRing,
                'text-foreground flex w-full items-center justify-between px-3 py-2 text-left font-medium'
              )}
            >
              {item.title}
              <ChevronDown
                className={cn(
                  'h-4 w-4 transition-transform',
                  open && 'rotate-180'
                )}
                aria-hidden="true"
              />
            </button>
            {open ? (
              <p id={panelId} className="text-secondary px-3 pb-2.5 text-sm">
                {item.body}
              </p>
            ) : null}
          </div>
        );
      })}
    </div>
  );
}

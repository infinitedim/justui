'use client';
/* eslint-disable jsx-a11y/no-noninteractive-tabindex -- a scrollable region must be focusable so keyboard users can scroll it (WCAG 2.1.1). */

import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function ScrollAreaMock() {
  const { crm } = useCatalogI18n();

  return (
    <section
      aria-label={crm.scrollArea.label}
      tabIndex={0}
      data-testid="mock-scroll-area"
      className={cn(surface, focusRing, 'h-32 w-full max-w-64 overflow-y-auto')}
    >
      <p className="text-muted bg-card sticky top-0 px-3 pt-2 pb-1 text-xs font-medium">
        {crm.scrollArea.label}
      </p>
      <ul className="divide-border divide-y px-3 text-sm">
        {crm.scrollArea.items.map((item) => (
          <li key={item} className="text-foreground py-1.5">
            {item}
          </li>
        ))}
      </ul>
    </section>
  );
}

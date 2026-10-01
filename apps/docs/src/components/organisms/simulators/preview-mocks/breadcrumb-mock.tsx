'use client';

import { ChevronRight } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';

export function BreadcrumbMock() {
  const { crm } = useCatalogI18n();
  const items = crm.breadcrumb.items;

  return (
    <nav aria-label={crm.breadcrumb.label} data-testid="mock-breadcrumb">
      <ol className="flex flex-wrap items-center gap-1.5 text-sm">
        {items.map((item, index) => {
          const current = index === items.length - 1;
          return (
            <li key={item} className="flex items-center gap-1.5">
              {index > 0 ? (
                <ChevronRight
                  className="text-muted h-3.5 w-3.5"
                  aria-hidden="true"
                />
              ) : null}
              <span
                aria-current={current ? 'page' : undefined}
                className={
                  current ? 'text-foreground font-medium' : 'text-muted'
                }
              >
                {item}
              </span>
            </li>
          );
        })}
      </ol>
    </nav>
  );
}

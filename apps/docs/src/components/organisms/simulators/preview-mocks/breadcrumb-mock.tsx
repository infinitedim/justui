'use client';

import { ChevronRight } from 'lucide-react';

export function BreadcrumbMock() {
  return (
    <nav aria-label="Breadcrumb" data-testid="mock-breadcrumb">
      <ol className="flex items-center gap-1.5 text-sm">
        <li className="text-secondary">Shop</li>
        <ChevronRight className="text-muted h-3.5 w-3.5" aria-hidden="true" />
        <li className="text-secondary">Orders</li>
        <ChevronRight className="text-muted h-3.5 w-3.5" aria-hidden="true" />
        <li className="text-foreground font-medium" aria-current="page">
          #1042
        </li>
      </ol>
    </nav>
  );
}

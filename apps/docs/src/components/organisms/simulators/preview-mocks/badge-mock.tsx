'use client';

import { cn } from '@/lib/cn';

const badge =
  'inline-flex items-center rounded-(--just-radius-sm) border-(length:--just-border-width) px-2 py-0.5 text-xs font-medium';

export function BadgeMock() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-2">
      <span
        data-testid="mock-badge-0"
        className={cn(badge, 'bg-accent text-accent-foreground border-border')}
      >
        Paid
      </span>
      <span
        data-testid="mock-badge-1"
        className={cn(badge, 'bg-card text-foreground border-border')}
      >
        Shipped
      </span>
      <span
        data-testid="mock-badge-2"
        className={cn(badge, 'bg-fill text-secondary border-transparent')}
      >
        Refunded
      </span>
    </div>
  );
}

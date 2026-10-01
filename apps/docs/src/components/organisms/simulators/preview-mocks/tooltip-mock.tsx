'use client';

import { useId, useState } from 'react';
import { Clock } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { neutralControl, raised } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

/** Opens on hover and on keyboard focus; Escape closes it (WCAG 1.4.13). */
export function TooltipMock() {
  const { crm } = useCatalogI18n();
  const [open, setOpen] = useState(false);
  const tooltipId = useId();

  return (
    <div className="relative inline-flex flex-col items-center">
      {open ? (
        <div
          id={tooltipId}
          role="tooltip"
          data-testid="mock-tooltip-bubble"
          className={cn(
            raised,
            'bg-elevated text-foreground absolute bottom-full mb-2 w-max max-w-56 px-2.5 py-1.5 text-xs'
          )}
        >
          {crm.tooltip.bubble}
        </div>
      ) : null}
      <button
        type="button"
        aria-describedby={open ? tooltipId : undefined}
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
        onFocus={() => setOpen(true)}
        onBlur={() => setOpen(false)}
        onKeyDown={(e) => {
          if (e.key === 'Escape') setOpen(false);
        }}
        data-testid="mock-tooltip-trigger"
        className={cn(
          neutralControl,
          'inline-flex h-9 items-center gap-1.5 px-3 text-sm'
        )}
      >
        <Clock className="text-muted h-4 w-4" aria-hidden="true" />
        {crm.tooltip.trigger}
      </button>
    </div>
  );
}

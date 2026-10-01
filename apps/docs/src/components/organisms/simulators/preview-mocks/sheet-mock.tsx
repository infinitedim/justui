'use client';

import { useEffect, useId, useRef, useState } from 'react';
import { Phone, X } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import {
  focusRing,
  neutralControl,
  surface,
  tokenBorder,
} from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

export function SheetMock() {
  const { crm } = useCatalogI18n();
  const [open, setOpen] = useState(false);
  const titleId = useId();
  const triggerRef = useRef<HTMLButtonElement>(null);
  const closeRef = useRef<HTMLButtonElement>(null);
  const wasOpen = useRef(false);

  useEffect(() => {
    if (open) closeRef.current?.focus();
    else if (wasOpen.current) triggerRef.current?.focus();
    wasOpen.current = open;
  }, [open]);

  return (
    <div
      className={cn(surface, 'relative h-36 w-full max-w-64 overflow-hidden')}
    >
      <div className="flex items-center justify-between gap-2 p-3">
        <div className="min-w-0">
          <p className="text-foreground truncate text-sm font-medium">
            {crm.sheet.title}
          </p>
          <p className="text-muted truncate text-xs">Warung Nusantara</p>
        </div>
        <button
          ref={triggerRef}
          type="button"
          onClick={() => setOpen(true)}
          aria-expanded={open}
          data-testid="mock-sheet-trigger"
          className={cn(neutralControl, 'h-8 shrink-0 px-3 text-xs')}
        >
          {crm.sheet.trigger}
        </button>
      </div>

      {open ? (
        <div
          role="dialog"
          aria-labelledby={titleId}
          data-testid="mock-sheet-panel"
          onKeyDown={(e) => {
            if (e.key === 'Escape') setOpen(false);
          }}
          className={cn(
            'bg-elevated absolute inset-y-0 right-0 flex w-3/4 flex-col gap-1.5 border-l-(length:--just-border-width) p-3 shadow-md',
            tokenBorder
          )}
        >
          <div className="flex items-center justify-between">
            <h4 id={titleId} className="text-foreground text-sm font-semibold">
              {crm.sheet.title}
            </h4>
            <button
              ref={closeRef}
              type="button"
              onClick={() => setOpen(false)}
              aria-label={crm.sheet.dismiss}
              className={cn(
                focusRing,
                'text-muted hover:text-foreground rounded-(--just-radius-sm) p-0.5'
              )}
            >
              <X className="h-4 w-4" aria-hidden="true" />
            </button>
          </div>
          <p className="text-foreground flex items-center gap-1.5 text-sm tabular-nums">
            <Phone className="text-muted h-3.5 w-3.5" aria-hidden="true" />
            {crm.sheet.phone}
          </p>
          <p className="text-muted text-xs">{crm.sheet.lastContact}</p>
        </div>
      ) : null}
    </div>
  );
}

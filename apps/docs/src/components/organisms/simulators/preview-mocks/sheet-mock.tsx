'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { outlineButton } from './mock-styles';

export function SheetMock() {
  const [open, setOpen] = useState(false);

  return (
    <div className="relative flex h-full w-full items-center justify-center">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
        data-testid="mock-sheet-trigger"
        className={outlineButton}
      >
        Filters
      </button>
      {open ? (
        <div
          role="dialog"
          aria-label="Filters"
          data-testid="mock-sheet-panel"
          className="bg-card border-border absolute top-0 right-0 bottom-0 z-20 flex w-40 flex-col justify-between border-l border-l-(length:--just-border-width) p-3 text-sm shadow-md"
        >
          <div className="space-y-1">
            <div className="font-semibold">Filters</div>
            <p className="text-secondary">Last 30 days, paid only</p>
          </div>
          <button
            type="button"
            onClick={() => setOpen(false)}
            className={cn(outlineButton, 'h-8 w-full text-xs')}
          >
            Apply
          </button>
        </div>
      ) : null}
    </div>
  );
}

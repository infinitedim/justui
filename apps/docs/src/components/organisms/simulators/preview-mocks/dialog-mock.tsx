'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { outlineButton, raised } from './mock-styles';

export function DialogMock() {
  const [open, setOpen] = useState(false);

  return (
    <div className="relative flex w-full flex-col items-center justify-center">
      <button
        type="button"
        onClick={() => setOpen(true)}
        data-testid="mock-dialog-trigger"
        className={outlineButton}
      >
        Remove address
      </button>

      {open ? (
        <div
          role="dialog"
          aria-modal="false"
          aria-labelledby="mock-dialog-title"
          data-testid="mock-dialog-content"
          className={cn(raised, 'absolute z-30 w-60 p-4 shadow-md')}
        >
          <h4 id="mock-dialog-title" className="text-sm font-semibold">
            Remove this address?
          </h4>
          <p className="text-secondary mt-1 text-sm">
            12 Baker St will no longer appear at checkout.
          </p>
          <div className="mt-4 flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setOpen(false)}
              className={cn(outlineButton, 'h-8 px-3 text-xs')}
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={() => setOpen(false)}
              className={cn(
                outlineButton,
                'bg-destructive-solid text-on-destructive hover:bg-destructive-solid h-8 px-3 text-xs'
              )}
            >
              Remove
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}

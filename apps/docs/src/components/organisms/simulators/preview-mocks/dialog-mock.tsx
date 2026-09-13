'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { X } from 'lucide-react';

export function DialogMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [open, setOpen] = useState(false);
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="relative flex w-full flex-col items-center justify-center">
      <button
        type="button"
        onClick={() => setOpen(true)}
        data-testid="mock-dialog-trigger"
        className={cn(
          'px-3.5 py-1.5 font-mono text-xs transition-all select-none',
          isNeo
            ? 'bg-surface text-foreground rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] active:translate-x-0.5 active:translate-y-0.5 dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
            : 'border-border bg-surface text-foreground hover:border-accent rounded-md border'
        )}
      >
        Open Dialog
      </button>

      {open ? (
        <div
          data-testid="mock-dialog-content"
          className={cn(
            'bg-surface absolute z-30 w-56 p-3 font-mono text-xs transition-all',
            isNeo
              ? 'rounded-md border-2 border-black shadow-[4px_4px_0px_0px_#000] dark:border-white dark:shadow-[4px_4px_0px_0px_#fff]'
              : 'border-border rounded-lg border shadow-xl'
          )}
        >
          <div className="flex items-center justify-between font-bold">
            <span>Confirm Action</span>
            <button
              type="button"
              onClick={() => setOpen(false)}
              aria-label="Close"
              className="hover:text-accent"
            >
              <X className="h-3.5 w-3.5" />
            </button>
          </div>
          <p className="text-muted mt-1.5 text-[11px]">
            Are you sure you want to initialize?
          </p>
          <div className="mt-3 flex justify-end gap-2">
            <button
              type="button"
              onClick={() => setOpen(false)}
              className={cn(
                'px-2 py-1 text-[10px]',
                isNeo
                  ? 'bg-accent border border-black font-bold text-black dark:border-white'
                  : 'bg-foreground text-background rounded'
              )}
            >
              Confirm
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}

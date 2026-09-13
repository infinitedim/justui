'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { PanelRightClose, PanelRightOpen } from 'lucide-react';

export function SheetMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [open, setOpen] = useState(false);
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="relative flex h-full w-full items-center justify-center">
      <button
        type="button"
        onClick={() => setOpen(!open)}
        data-testid="mock-sheet-trigger"
        className={cn(
          'flex items-center gap-1.5 px-3 py-1.5 font-mono text-xs transition-all select-none',
          isNeo
            ? 'bg-surface text-foreground rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] active:translate-x-0.5 active:translate-y-0.5 dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
            : 'border-border bg-surface text-foreground hover:border-accent rounded-md border'
        )}
      >
        {open ? (
          <PanelRightClose className="h-3.5 w-3.5" />
        ) : (
          <PanelRightOpen className="h-3.5 w-3.5" />
        )}
        <span>{open ? 'Close Sheet' : 'Open Sheet'}</span>
      </button>

      {open ? (
        <div
          data-testid="mock-sheet-panel"
          className={cn(
            'bg-surface absolute top-0 right-0 bottom-0 z-20 flex w-36 flex-col justify-between p-2.5 font-mono text-[11px] transition-all',
            isNeo
              ? 'border-l-2 border-black shadow-[-3px_0px_0px_0px_#000] dark:border-white dark:shadow-[-3px_0px_0px_0px_#fff]'
              : 'border-border border-l shadow-md'
          )}
        >
          <div>
            <div className="text-foreground font-bold">Drawer Panel</div>
            <p className="text-muted mt-1">Contextual options</p>
          </div>
          <button
            type="button"
            onClick={() => setOpen(false)}
            className="text-accent text-left hover:underline"
          >
            Dismiss
          </button>
        </div>
      ) : null}
    </div>
  );
}

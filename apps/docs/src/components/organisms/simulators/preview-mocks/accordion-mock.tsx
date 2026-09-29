'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { ChevronDown } from 'lucide-react';

export function AccordionMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [open, setOpen] = useState(false);
  const isNeo = preset === 'neobrutalism';

  return (
    <div
      data-testid="mock-accordion"
      className={cn(
        'w-full max-w-60 overflow-hidden font-mono text-xs transition-all',
        isNeo
          ? 'bg-surface rounded-none border-[2.5px] border-black shadow-[4px_4px_0px_0px_#000] dark:border-white dark:shadow-[4px_4px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-md border shadow-sm'
      )}
    >
      <button
        type="button"
        onClick={() => setOpen(!open)}
        className="flex w-full items-center justify-between p-2.5 text-left font-medium select-none"
      >
        <span>Zero-Dependency?</span>
        <ChevronDown
          className={cn(
            'h-4 w-4 transition-transform duration-200',
            open && 'rotate-180'
          )}
        />
      </button>

      {open ? (
        <div
          className={cn(
            'p-2.5 text-[11px] leading-relaxed',
            isNeo
              ? 'border-t-[2.5px] border-black text-foreground dark:border-white'
              : 'border-border text-muted bg-surface-muted/50 border-t'
          )}
        >
          Yes. All widgets are copied directly into your workspace.
        </div>
      ) : null}
    </div>
  );
}

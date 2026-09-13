'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { ChevronDown } from 'lucide-react';

export function SelectMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [selected, setSelected] = useState('Flutter WASM');
  const [open, setOpen] = useState(false);
  const isNeo = preset === 'neobrutalism';

  const options = ['Flutter WASM', 'CanvasKit', 'HTML Renderer'];

  return (
    <div className="relative w-full max-w-50">
      <button
        type="button"
        onClick={() => setOpen(!open)}
        data-testid="mock-select-trigger"
        className={cn(
          'flex w-full items-center justify-between px-3 py-1.5 font-mono text-xs transition-all',
          isNeo
            ? 'bg-surface text-foreground rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
            : 'border-border bg-surface text-foreground rounded-md border shadow-sm'
        )}
      >
        <span>{selected}</span>
        <ChevronDown
          className={cn(
            'h-3.5 w-3.5 transition-transform',
            open && 'rotate-180'
          )}
        />
      </button>

      {open ? (
        <div
          data-testid="mock-select-menu"
          className={cn(
            'bg-surface absolute top-full left-0 z-20 mt-1.5 w-full overflow-hidden py-1 font-mono text-xs',
            isNeo
              ? 'rounded-md border-2 border-black shadow-[3px_3px_0px_0px_#000] dark:border-white dark:shadow-[3px_3px_0px_0px_#fff]'
              : 'border-border rounded-md border shadow-md'
          )}
        >
          {options.map((opt) => (
            <button
              key={opt}
              type="button"
              onClick={() => {
                setSelected(opt);
                setOpen(false);
              }}
              className={cn(
                'w-full px-3 py-1.5 text-left transition-colors',
                selected === opt
                  ? 'bg-accent/20 text-accent-deep dark:text-accent font-bold'
                  : 'hover:bg-surface-muted'
              )}
            >
              {opt}
            </button>
          ))}
        </div>
      ) : null}
    </div>
  );
}

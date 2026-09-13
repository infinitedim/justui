'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { HelpCircle } from 'lucide-react';

export function TooltipMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [hover, setHover] = useState(false);
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="relative flex flex-col items-center justify-center">
      {hover ? (
        <div
          data-testid="mock-tooltip-bubble"
          className={cn(
            'absolute -top-9 px-2.5 py-1 font-mono text-[10px] whitespace-nowrap transition-all',
            isNeo
              ? 'bg-accent rounded border border-black font-bold text-black shadow-[2px_2px_0px_0px_#000] dark:border-white'
              : 'bg-foreground text-background rounded shadow-md'
          )}
        >
          WCAG AA 4.5:1 compliant
        </div>
      ) : null}

      <button
        type="button"
        onMouseEnter={() => setHover(true)}
        onMouseLeave={() => setHover(false)}
        onClick={() => setHover(!hover)}
        aria-label="Information"
        data-testid="mock-tooltip-trigger"
        className={cn(
          'p-2 transition-all select-none',
          isNeo
            ? 'bg-surface text-foreground rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
            : 'border-border bg-surface hover:border-accent rounded-full border'
        )}
      >
        <HelpCircle className="h-4 w-4" />
      </button>
    </div>
  );
}

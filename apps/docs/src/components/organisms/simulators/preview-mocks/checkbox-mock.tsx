'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { Check } from 'lucide-react';

export function CheckboxMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [checked, setChecked] = useState(true);
  const isNeo = preset === 'neobrutalism';

  return (
    <div
      onClick={() => setChecked(!checked)}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          setChecked(!checked);
        }
      }}
      role="button"
      tabIndex={0}
      data-testid="mock-checkbox"
      className="flex cursor-pointer items-center gap-2.5 select-none"
    >
      <div
        className={cn(
          'flex h-5 w-5 items-center justify-center transition-all',
          isNeo
            ? 'bg-surface rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
            : 'border-border bg-surface rounded border',
          checked && (isNeo ? 'bg-accent' : 'border-accent bg-accent')
        )}
      >
        {checked ? (
          <Check
            className={cn(
              'h-3.5 w-3.5',
              isNeo ? 'font-bold text-black' : 'text-foreground'
            )}
          />
        ) : null}
      </div>
      <span className="text-foreground font-mono text-xs font-medium">
        Enable Telemetry
      </span>
    </div>
  );
}

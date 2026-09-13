'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function SwitchMock({
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
      data-testid="mock-switch"
      className="flex cursor-pointer items-center gap-3 select-none"
    >
      <div
        className={cn(
          'relative h-6 w-11 transition-all',
          isNeo
            ? 'bg-surface rounded-full border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
            : 'border-border bg-surface-muted rounded-full border',
          checked && (isNeo ? 'bg-accent' : 'bg-accent')
        )}
      >
        <div
          className={cn(
            'absolute top-0.5 h-4 w-4 rounded-full transition-all duration-200',
            isNeo
              ? 'border border-black bg-white dark:border-black'
              : 'bg-foreground shadow-sm',
            checked ? 'left-5.5' : 'left-0.5'
          )}
        />
      </div>
      <span className="text-foreground font-mono text-xs font-medium">
        {checked ? 'Active' : 'Inactive'}
      </span>
    </div>
  );
}

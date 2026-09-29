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
          'relative h-7 w-12 transition-all',
          isNeo
            ? 'rounded-full border-[2.5px] border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
            : 'border-border bg-surface-muted rounded-full border',
          checked ? (isNeo ? 'bg-accent' : 'bg-accent') : 'bg-surface'
        )}
      >
        <div
          className={cn(
            'absolute top-[2.5px] h-[18px] w-[18px] rounded-full transition-all',
            isNeo ? 'duration-0 border-[2px] border-black bg-white dark:border-black' : 'duration-200 bg-foreground shadow-sm',
            checked ? 'left-[22px]' : 'left-[2.5px]'
          )}
        />
      </div>
      <span className="text-foreground font-mono text-xs font-medium">
        {checked ? 'Active' : 'Inactive'}
      </span>
    </div>
  );
}

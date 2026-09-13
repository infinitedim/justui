'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function ProgressMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [val, setVal] = useState(68);
  const isNeo = preset === 'neobrutalism';

  const stepProgress = () => {
    setVal((v) => (v >= 100 ? 25 : v + 15));
  };

  return (
    <div className="w-full max-w-[220px] space-y-2">
      <div className="text-muted flex items-center justify-between font-mono text-[11px]">
        <span>Build Progress</span>
        <span>{val}%</span>
      </div>
      <div
        onClick={stepProgress}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            stepProgress();
          }
        }}
        role="button"
        tabIndex={0}
        data-testid="mock-progress"
        className={cn(
          'relative h-4 w-full cursor-pointer overflow-hidden transition-all select-none',
          isNeo
            ? 'bg-surface rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
            : 'border-border bg-surface-muted rounded-full border'
        )}
      >
        <div
          style={{ width: `${val}%` }}
          className={cn(
            'h-full transition-all duration-300',
            isNeo
              ? 'bg-accent border-r-2 border-black dark:border-white'
              : 'bg-accent rounded-full'
          )}
        />
      </div>
      <p className="text-muted text-center font-mono text-[10px]">
        Click bar to advance
      </p>
    </div>
  );
}

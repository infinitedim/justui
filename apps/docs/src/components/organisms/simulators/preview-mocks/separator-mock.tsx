'use client';

import React from 'react';
import { cn } from '@/lib/cn';

export function SeparatorMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const isNeo = preset === 'neobrutalism';

  return (
    <div
      data-testid="mock-separator"
      className="w-full max-w-50 space-y-3 text-center font-mono text-xs"
    >
      <div className="flex items-center justify-center gap-3">
        <span className="text-muted">Core</span>
        <div
          className={cn(
            'h-3.5 w-px',
            isNeo ? 'w-0.5 bg-black dark:bg-white' : 'bg-border'
          )}
        />
        <span className="text-foreground font-medium">Tokens</span>
        <div
          className={cn(
            'h-3.5 w-px',
            isNeo ? 'w-0.5 bg-black dark:bg-white' : 'bg-border'
          )}
        />
        <span className="text-muted">CLI</span>
      </div>
      <div
        className={cn(
          'h-px w-full',
          isNeo ? 'h-0.5 bg-black dark:bg-white' : 'bg-border'
        )}
      />
      <span className="text-muted block text-[10px]">Bresenham Partition</span>
    </div>
  );
}

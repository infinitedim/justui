'use client';

import React from 'react';
import { cn } from '@/lib/cn';

export function ScrollAreaMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const isNeo = preset === 'neobrutalism';
  const items = [
    'Tokens',
    'Theming',
    'Bresenham',
    'Invariance',
    'InheritedModel',
    'Contrast AA',
  ];

  return (
    <div
      data-testid="mock-scroll-area"
      className={cn(
        'h-28 w-full max-w-50 space-y-1 overflow-y-auto p-2 font-mono text-xs select-none',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-md border'
      )}
    >
      {items.map((item, i) => (
        <div
          key={item}
          className={cn(
            'rounded px-2 py-1 text-[11px] transition-colors',
            i === 0
              ? 'bg-accent/20 text-accent-deep dark:text-accent font-bold'
              : 'text-muted hover:text-foreground'
          )}
        >
          {i + 1}. {item}
        </div>
      ))}
    </div>
  );
}

'use client';

import React from 'react';
import { cn } from '@/lib/cn';

export function TableMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const isNeo = preset === 'neobrutalism';

  const rows = [
    { name: 'button', category: 'primitive', dep: '0' },
    { name: 'switch', category: 'selection', dep: '0' },
    { name: 'sidebar', category: 'navigation', dep: '0' },
  ];

  return (
    <div
      data-testid="mock-table"
      className={cn(
        'w-full max-w-60 overflow-hidden font-mono text-[10px] select-none',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-md border'
      )}
    >
      <div className="border-border bg-surface-muted/60 grid grid-cols-3 border-b p-1.5 font-bold">
        <span>Component</span>
        <span>Type</span>
        <span className="text-right">External</span>
      </div>
      {rows.map((r, i) => (
        <div
          key={r.name}
          className={cn(
            'grid grid-cols-3 p-1.5 transition-colors',
            i < rows.length - 1 && 'border-border/50 border-b',
            'hover:bg-accent/10'
          )}
        >
          <span className="text-foreground font-medium">{r.name}</span>
          <span className="text-muted">{r.category}</span>
          <span className="text-accent text-right font-bold">{r.dep}</span>
        </div>
      ))}
    </div>
  );
}

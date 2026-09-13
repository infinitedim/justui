'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function TabsMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [active, setActive] = useState('preview');
  const isNeo = preset === 'neobrutalism';

  const tabs = [
    { id: 'preview', label: 'Preview' },
    { id: 'code', label: 'Code' },
    { id: 'api', label: 'API' },
  ];

  return (
    <div
      data-testid="mock-tabs"
      className={cn(
        'inline-flex gap-1 p-1 font-mono text-xs select-none',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
          : 'border-border bg-surface-muted/50 rounded-lg border'
      )}
    >
      {tabs.map((t) => {
        const isSelected = active === t.id;
        return (
          <button
            key={t.id}
            type="button"
            onClick={() => setActive(t.id)}
            data-testid={`mock-tab-${t.id}`}
            className={cn(
              'px-3 py-1 transition-all',
              isNeo ? 'rounded' : 'rounded-md',
              isSelected
                ? isNeo
                  ? 'bg-accent border border-black font-bold text-black dark:border-white'
                  : 'bg-surface text-foreground font-medium shadow-sm'
                : 'text-muted hover:text-foreground'
            )}
          >
            {t.label}
          </button>
        );
      })}
    </div>
  );
}

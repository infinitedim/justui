'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function BadgeMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [activeBadge, setActiveBadge] = useState<number>(0);
  const isNeo = preset === 'neobrutalism';

  const badges = [
    {
      label: 'Stable',
      color:
        'bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border-emerald-500/30',
    },
    {
      label: 'WASM Ready',
      color: 'bg-accent/15 text-accent-deep dark:text-accent border-accent/30',
    },
    {
      label: 'v0.13.2',
      color:
        'bg-purple-500/15 text-purple-600 dark:text-purple-400 border-purple-500/30',
    },
  ];

  return (
    <div className="flex flex-wrap items-center justify-center gap-2">
      {badges.map((b, idx) => (
        <button
          key={b.label}
          type="button"
          onClick={() => setActiveBadge(idx)}
          data-testid={`mock-badge-${idx}`}
          className={cn(
            'px-2.5 py-1 font-mono text-xs transition-all select-none',
            isNeo
              ? 'rounded-md border-2 border-black font-bold text-black dark:border-white dark:text-white'
              : 'rounded-full border text-xs',
            isNeo && activeBadge === idx
              ? 'bg-accent -translate-x-px -translate-y-px shadow-[2px_2px_0px_0px_#000] dark:shadow-[2px_2px_0px_0px_#fff]'
              : isNeo
                ? 'bg-surface'
                : b.color,
            !isNeo && activeBadge === idx && 'ring-accent ring-2'
          )}
        >
          {b.label}
        </button>
      ))}
    </div>
  );
}

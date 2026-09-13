'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function CardMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [clicked, setClicked] = useState(false);
  const isNeo = preset === 'neobrutalism';

  return (
    <div
      data-testid="mock-card"
      className={cn(
        'w-full max-w-[220px] p-3 font-mono text-xs transition-all',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[3px_3px_0px_0px_#000] dark:border-white dark:shadow-[3px_3px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-lg border shadow-sm'
      )}
    >
      <div className="text-foreground font-bold">Memory Heap</div>
      <p className="text-muted mt-1 text-[11px]">
        Zero ephemeral allocations during tick.
      </p>
      <button
        type="button"
        onClick={() => setClicked(!clicked)}
        className={cn(
          'mt-2.5 px-2 py-1 text-[10px] font-medium transition-all select-none',
          isNeo
            ? 'bg-accent border border-black font-bold text-black dark:border-white'
            : 'border-border bg-surface-muted text-foreground hover:border-accent rounded border'
        )}
      >
        {clicked ? 'Optimized' : 'Profile'}
      </button>
    </div>
  );
}

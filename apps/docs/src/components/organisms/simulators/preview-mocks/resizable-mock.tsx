'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function ResizableMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [split, setSplit] = useState(50);
  const isNeo = preset === 'neobrutalism';

  const toggleSplit = () => {
    setSplit((s) => (s === 50 ? 65 : s === 65 ? 35 : 50));
  };

  return (
    <div
      onClick={toggleSplit}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          toggleSplit();
        }
      }}
      role="button"
      tabIndex={0}
      data-testid="mock-resizable"
      className={cn(
        'flex h-20 w-full max-w-60 cursor-pointer overflow-hidden font-mono text-[11px] select-none',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-md border'
      )}
    >
      <div
        style={{ width: `${split}%` }}
        className="bg-surface-muted/40 text-muted flex items-center justify-center p-2 transition-all duration-300"
      >
        Left ({split}%)
      </div>
      <div
        className={cn(
          'flex w-1.5 items-center justify-center transition-colors',
          isNeo ? 'bg-black dark:bg-white' : 'bg-border'
        )}
      />
      <div
        style={{ width: `${100 - split}%` }}
        className="text-foreground flex items-center justify-center p-2 font-medium transition-all duration-300"
      >
        Right ({100 - split}%)
      </div>
    </div>
  );
}

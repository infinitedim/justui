'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function AvatarMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [online, setOnline] = useState(true);
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="flex flex-col items-center gap-2">
      <div
        onClick={() => setOnline(!online)}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            setOnline(!online);
          }
        }}
        role="button"
        tabIndex={0}
        data-testid="mock-avatar"
        className="relative cursor-pointer select-none"
      >
        <div
          className={cn(
            'flex h-12 w-12 items-center justify-center font-mono font-bold transition-all',
            isNeo
              ? 'bg-accent text-black rounded-full border-[2.5px] border-black shadow-[4px_4px_0px_0px_#000] dark:border-white dark:shadow-[4px_4px_0px_0px_#fff]'
              : 'border-border bg-foreground text-background rounded-full border shadow-sm'
          )}
        >
          JU
        </div>
        <span
          className={cn(
            'absolute -right-0.5 -bottom-0.5 h-3.5 w-3.5 rounded-full border-2 transition-colors',
            isNeo ? 'border-black dark:border-white' : 'border-surface',
            online ? 'bg-emerald-500' : 'bg-zinc-400'
          )}
        />
      </div>
      <span className="text-muted font-mono text-[11px]">
        {online ? 'Online (Click to toggle)' : 'Offline (Click to toggle)'}
      </span>
    </div>
  );
}

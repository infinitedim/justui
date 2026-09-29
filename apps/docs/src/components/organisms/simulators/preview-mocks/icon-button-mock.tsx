'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { Heart } from 'lucide-react';

export function IconButtonMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [active, setActive] = useState(false);
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="flex items-center gap-3">
      <button
        type="button"
        onClick={() => setActive(!active)}
        aria-label="Favorite"
        data-testid="mock-icon-button"
        className={cn(
          'relative inline-flex h-10 w-10 items-center justify-center transition-all select-none',
          isNeo
            ? 'bg-surface rounded-none border-[2.5px] border-black shadow-[4px_4px_0px_0px_#000] active:translate-x-1 active:translate-y-1 active:shadow-none dark:border-white dark:shadow-[4px_4px_0px_0px_#fff]'
            : 'border-border bg-surface hover:border-accent rounded-full border shadow-sm'
        )}
      >
        <Heart
          className={cn(
            'h-5 w-5 transition-colors',
            active ? 'fill-red-500 text-red-500' : 'text-foreground'
          )}
        />
      </button>
      <span className="text-muted font-mono text-xs">
        {active ? 'Liked!' : 'Click to like'}
      </span>
    </div>
  );
}

'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function ButtonMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [count, setCount] = useState(0);
  const isNeo = preset === 'neobrutalism';

  return (
    <button
      type="button"
      onClick={() => setCount((c) => c + 1)}
      data-testid="mock-button"
      className={cn(
        'relative inline-flex items-center justify-center font-medium transition-all select-none',
        'px-4 py-2 text-sm active:scale-95',
        isNeo
          ? 'bg-accent rounded-md border-2 border-black font-mono font-bold text-black shadow-[3px_3px_0px_0px_#000] active:translate-x-0.5 active:translate-y-0.5 dark:border-white dark:text-black dark:shadow-[3px_3px_0px_0px_#fff]'
          : 'bg-foreground text-background rounded-md shadow-sm hover:opacity-90 active:scale-98'
      )}
    >
      Click Me {count > 0 ? `(${count})` : ''}
    </button>
  );
}

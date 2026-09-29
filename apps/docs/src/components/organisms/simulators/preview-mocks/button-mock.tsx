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
        'relative inline-flex items-center justify-center font-medium select-none px-4 py-2 text-sm',
        isNeo
          ? 'just-press bg-accent text-black rounded-none border-[2.5px] border-black font-bold shadow-[4px_4px_0px_0px_#000] dark:border-white dark:shadow-[4px_4px_0px_0px_#fff] active:translate-x-1 active:translate-y-1 active:shadow-none'
          : 'bg-foreground text-background rounded-md shadow-sm hover:opacity-90 active:scale-98 transition-all'
      )}
    >
      Click Me {count > 0 ? `(${count})` : ''}
    </button>
  );
}

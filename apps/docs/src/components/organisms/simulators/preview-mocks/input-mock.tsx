'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function InputMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [val, setVal] = useState('Flutter developer');
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="w-full max-w-60 space-y-1.5">
      <label
        htmlFor="mock-user-handle-input"
        className="text-muted block font-mono text-xs"
      >
        User Handle
      </label>
      <input
        id="mock-user-handle-input"
        type="text"
        value={val}
        onChange={(e) => setVal(e.target.value)}
        data-testid="mock-input"
        className={cn(
          'w-full px-3 py-1.5 font-mono text-xs transition-all outline-none',
          isNeo
            ? 'bg-surface text-foreground rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
            : 'bg-surface text-foreground focus:border-accent focus:ring-accent rounded-md border focus:ring-1'
        )}
      />
    </div>
  );
}

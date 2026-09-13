'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function SliderMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [val, setVal] = useState(75);
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="w-full max-w-55 space-y-2">
      <div className="text-muted flex items-center justify-between font-mono text-xs">
        <span>Lightness</span>
        <span className="text-foreground font-bold">{val}%</span>
      </div>
      <input
        type="range"
        min={0}
        max={100}
        value={val}
        onChange={(e) => setVal(Number(e.target.value))}
        data-testid="mock-slider"
        className={cn(
          'accent-accent w-full cursor-pointer',
          isNeo &&
            'bg-surface h-3 rounded-none border-2 border-black dark:border-white'
        )}
      />
    </div>
  );
}

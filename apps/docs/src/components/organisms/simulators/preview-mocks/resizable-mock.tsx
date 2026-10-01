'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { focusRing, surface } from './mock-styles';

const splits = [50, 65, 35];

export function ResizableMock() {
  const [index, setIndex] = useState(0);
  const split = splits[index] ?? 50;

  return (
    <button
      type="button"
      onClick={() => setIndex((i) => (i + 1) % splits.length)}
      aria-label={`Orders ${split}%, details ${100 - split}%. Change split`}
      data-testid="mock-resizable"
      className={cn(
        surface,
        'flex h-24 w-full max-w-60 overflow-hidden text-sm',
        focusRing
      )}
    >
      <span
        style={{ width: `${split}%` }}
        className="text-secondary flex flex-col justify-center gap-1 px-3 text-left"
      >
        <span>#1042</span>
        <span>#1038</span>
      </span>
      <span className="bg-border w-(--just-border-width)" aria-hidden="true" />
      <span
        style={{ width: `${100 - split}%` }}
        className="text-foreground flex items-center px-3 text-left font-medium"
      >
        #1042 details
      </span>
    </button>
  );
}

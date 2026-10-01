'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { focusRing } from './mock-styles';

export function SwitchMock() {
  const [checked, setChecked] = useState(true);

  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      onClick={() => setChecked((c) => !c)}
      data-testid="mock-switch"
      className={cn('flex items-center gap-3', focusRing)}
    >
      <span
        className={cn(
          'border-border relative inline-block h-7 w-12 rounded-full border-(length:--just-border-width)',
          checked ? 'bg-accent' : 'bg-fill'
        )}
      >
        <span
          className={cn(
            'bg-foreground absolute top-1/2 h-4.5 w-4.5 -translate-y-1/2 rounded-full',
            checked ? 'right-0.75' : 'left-0.75'
          )}
        />
      </span>
      <span className="text-foreground text-sm">
        Order updates {checked ? 'on' : 'off'}
      </span>
    </button>
  );
}

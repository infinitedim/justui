'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { focusRing, hint } from './mock-styles';

export function AvatarMock() {
  const [online, setOnline] = useState(true);

  return (
    <button
      type="button"
      onClick={() => setOnline((o) => !o)}
      data-testid="mock-avatar"
      className={cn('flex items-center gap-3 text-left', focusRing)}
    >
      <span className="relative">
        <span className="bg-fill text-foreground border-border flex h-11 w-11 items-center justify-center rounded-full border-(length:--just-border-width) text-sm font-semibold">
          AR
        </span>
        <span
          className={cn(
            'border-card absolute -right-0.5 -bottom-0.5 h-3.5 w-3.5 rounded-full border-2',
            online ? 'bg-success' : 'bg-fill'
          )}
          aria-hidden="true"
        />
      </span>
      <span>
        <span className="text-foreground block text-sm font-medium">
          Alex Rivera
        </span>
        <span className={hint}>{online ? 'Online' : 'Away'}</span>
      </span>
    </button>
  );
}

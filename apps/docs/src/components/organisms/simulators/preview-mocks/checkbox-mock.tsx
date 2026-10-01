'use client';

import { useState } from 'react';
import { Check } from 'lucide-react';
import { cn } from '@/lib/cn';
import { focusRing } from './mock-styles';

export function CheckboxMock() {
  const [checked, setChecked] = useState(true);

  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      onClick={() => setChecked((c) => !c)}
      data-testid="mock-checkbox"
      className={cn('flex items-center gap-2.5 text-left', focusRing)}
    >
      <span
        className={cn(
          'border-border flex h-5 w-5 items-center justify-center rounded-(--just-radius-sm) border-(length:--just-border-width)',
          checked ? 'bg-accent text-accent-foreground' : 'bg-card'
        )}
      >
        {checked ? (
          <Check className="h-3.5 w-3.5 stroke-3" aria-hidden="true" />
        ) : null}
      </span>
      <span className="text-foreground text-sm">Email me when it ships</span>
    </button>
  );
}

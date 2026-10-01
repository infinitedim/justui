'use client';

import { useState } from 'react';
import { cn } from '@/lib/cn';
import { focusRing, hint } from './mock-styles';

const steps = ['Ordered', 'Packed', 'Shipped', 'Delivered'];

export function ProgressMock() {
  const [step, setStep] = useState(2);
  const value = Math.round(((step + 1) / steps.length) * 100);

  return (
    <button
      type="button"
      onClick={() => setStep((s) => (s + 1) % steps.length)}
      data-testid="mock-progress"
      className={cn('w-full max-w-56 space-y-2 text-left', focusRing)}
    >
      <span className="flex items-center justify-between text-xs">
        <span className="text-foreground font-medium">Order #1042</span>
        <span className="text-secondary">{steps[step]}</span>
      </span>
      <span
        role="progressbar"
        aria-valuenow={value}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label="Delivery progress"
        className="bg-fill border-border block h-2.5 w-full overflow-hidden rounded-full border-(length:--just-border-width)"
      >
        <span
          className="bg-accent block h-full"
          style={{ width: `${value}%` }}
        />
      </span>
      <span className={cn(hint, 'block')}>Tap to move to the next step</span>
    </button>
  );
}

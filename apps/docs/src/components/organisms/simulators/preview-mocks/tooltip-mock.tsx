'use client';

import { useState } from 'react';
import { Info } from 'lucide-react';
import { cn } from '@/lib/cn';
import { focusRing, raised } from './mock-styles';

export function TooltipMock() {
  const [visible, setVisible] = useState(false);

  return (
    <div className="relative flex items-center gap-1.5 text-sm">
      <span className="text-secondary">Shipping $4.00</span>
      <button
        type="button"
        onMouseEnter={() => setVisible(true)}
        onMouseLeave={() => setVisible(false)}
        onFocus={() => setVisible(true)}
        onBlur={() => setVisible(false)}
        onClick={() => setVisible((v) => !v)}
        aria-label="About shipping"
        aria-describedby={visible ? 'mock-tooltip' : undefined}
        data-testid="mock-tooltip-trigger"
        className={cn('text-secondary hover:text-foreground', focusRing)}
      >
        <Info className="h-4 w-4" aria-hidden="true" />
      </button>
      {visible ? (
        <div
          id="mock-tooltip"
          role="tooltip"
          data-testid="mock-tooltip-bubble"
          className={cn(
            raised,
            'absolute -top-10 left-1/2 -translate-x-1/2 px-2.5 py-1 text-xs whitespace-nowrap'
          )}
        >
          Free on orders over $50
        </div>
      ) : null}
    </div>
  );
}

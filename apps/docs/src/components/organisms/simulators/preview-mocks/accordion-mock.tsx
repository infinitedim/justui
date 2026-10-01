'use client';

import { useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { cn } from '@/lib/cn';
import { raised } from './mock-styles';

export function AccordionMock() {
  const [open, setOpen] = useState(false);

  return (
    <div
      data-testid="mock-accordion"
      className={cn(raised, 'w-full max-w-60 overflow-hidden')}
    >
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
        className="flex w-full items-center justify-between gap-2 px-3 py-2.5 text-left text-sm font-medium"
      >
        <span>Can I change the address?</span>
        <ChevronDown
          className={cn('h-4 w-4 shrink-0', open && 'rotate-180')}
          aria-hidden="true"
        />
      </button>
      {open ? (
        <p className="text-secondary border-border border-t border-t-(length:--just-border-width) px-3 py-2.5 text-sm leading-relaxed">
          Yes, until the order is packed. Open the order and choose Edit
          address.
        </p>
      ) : null}
    </div>
  );
}

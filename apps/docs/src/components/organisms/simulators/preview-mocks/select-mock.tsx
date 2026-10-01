'use client';

import { useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { cn } from '@/lib/cn';
import { label, raised, surface } from './mock-styles';

const options = ['Standard, 3-5 days', 'Express, 1-2 days', 'Store pickup'];

export function SelectMock() {
  const [selected, setSelected] = useState(options[0]);
  const [open, setOpen] = useState(false);

  return (
    <div className="relative w-full max-w-56 space-y-1.5">
      <span className={cn(label, 'block')}>Shipping</span>
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
        data-testid="mock-select-trigger"
        className={cn(
          surface,
          'flex h-9 w-full items-center justify-between px-3 text-sm',
          'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-1'
        )}
      >
        <span>{selected}</span>
        <ChevronDown className="text-muted h-4 w-4" aria-hidden="true" />
      </button>
      {open ? (
        <div
          role="listbox"
          data-testid="mock-select-menu"
          className={cn(
            raised,
            'absolute top-full left-0 z-20 mt-1 w-full p-1'
          )}
        >
          {options.map((opt) => (
            <button
              key={opt}
              type="button"
              role="option"
              aria-selected={selected === opt}
              onClick={() => {
                setSelected(opt);
                setOpen(false);
              }}
              className={cn(
                'block w-full rounded-(--just-radius-sm) px-2.5 py-1.5 text-left text-sm',
                selected === opt
                  ? 'bg-accent-muted text-foreground font-medium'
                  : 'text-secondary hover:bg-accent-muted'
              )}
            >
              {opt}
            </button>
          ))}
        </div>
      ) : null}
    </div>
  );
}

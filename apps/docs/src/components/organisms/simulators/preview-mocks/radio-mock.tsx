'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function RadioMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [selected, setSelected] = useState('pro');
  const isNeo = preset === 'neobrutalism';

  const options = [
    { id: 'free', label: 'Starter' },
    { id: 'pro', label: 'Professional' },
  ];

  return (
    <div data-testid="mock-radio" className="space-y-2">
      {options.map((opt) => {
        const isChecked = selected === opt.id;
        return (
          <div
            key={opt.id}
            onClick={() => setSelected(opt.id)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                setSelected(opt.id);
              }
            }}
            role="button"
            tabIndex={0}
            data-testid={`mock-radio-${opt.id}`}
            className="flex cursor-pointer items-center gap-2.5 select-none"
          >
            <div
              className={cn(
                'flex h-4.5 w-4.5 items-center justify-center rounded-full transition-all',
                isNeo
                  ? 'bg-surface border-2 border-black dark:border-white'
                  : 'border-border bg-surface border',
                isChecked && (isNeo ? 'border-black' : 'border-accent')
              )}
            >
              {isChecked ? (
                <div
                  className={cn(
                    'h-2 w-2 rounded-full',
                    isNeo ? 'bg-black dark:bg-white' : 'bg-accent'
                  )}
                />
              ) : null}
            </div>
            <span className="text-foreground font-mono text-xs font-medium">
              {opt.label}
            </span>
          </div>
        );
      })}
    </div>
  );
}

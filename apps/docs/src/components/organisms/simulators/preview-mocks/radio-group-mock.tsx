'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';

export function RadioGroupMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [selected, setSelected] = useState('card');
  const isNeo = preset === 'neobrutalism';

  const methods = [
    { id: 'card', name: 'Credit Card' },
    { id: 'paypal', name: 'PayPal' },
    { id: 'crypto', name: 'Crypto (WASM)' },
  ];

  return (
    <div
      data-testid="mock-radio-group"
      className="w-full max-w-52.5 space-y-1.5 font-mono text-xs select-none"
    >
      {methods.map((m) => {
        const isChecked = selected === m.id;
        return (
          <div
            key={m.id}
            onClick={() => setSelected(m.id)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                setSelected(m.id);
              }
            }}
            role="button"
            tabIndex={0}
            data-testid={`mock-radio-group-${m.id}`}
            className={cn(
              'flex cursor-pointer items-center justify-between p-2 transition-all',
              isNeo
                ? 'bg-surface rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
                : 'border-border bg-surface rounded-md border',
              isChecked &&
                (isNeo
                  ? 'bg-accent/20 font-bold'
                  : 'border-accent bg-accent/10')
            )}
          >
            <span className="text-foreground">{m.name}</span>
            <div
              className={cn(
                'flex h-3.5 w-3.5 items-center justify-center rounded-full border',
                isNeo
                  ? 'border-2 border-black dark:border-white'
                  : 'border-border',
                isChecked && 'border-accent'
              )}
            >
              {isChecked ? (
                <div
                  className={cn(
                    'h-1.5 w-1.5 rounded-full',
                    isNeo ? 'bg-black dark:bg-white' : 'bg-accent'
                  )}
                />
              ) : null}
            </div>
          </div>
        );
      })}
    </div>
  );
}

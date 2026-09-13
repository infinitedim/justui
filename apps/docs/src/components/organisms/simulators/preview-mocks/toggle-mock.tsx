'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { Bold, Italic, Underline } from 'lucide-react';

export function ToggleMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [active, setActive] = useState<string[]>(['bold']);
  const isNeo = preset === 'neobrutalism';

  const toggle = (val: string) => {
    setActive((prev) =>
      prev.includes(val) ? prev.filter((x) => x !== val) : [...prev, val]
    );
  };

  const items = [
    { id: 'bold', icon: Bold },
    { id: 'italic', icon: Italic },
    { id: 'underline', icon: Underline },
  ];

  return (
    <div
      data-testid="mock-toggle"
      className={cn(
        'inline-flex gap-1 p-1',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-md border shadow-sm'
      )}
    >
      {items.map(({ id, icon: Icon }) => {
        const isSelected = active.includes(id);
        return (
          <button
            key={id}
            type="button"
            onClick={() => toggle(id)}
            data-testid={`mock-toggle-${id}`}
            className={cn(
              'flex h-8 w-8 items-center justify-center transition-all select-none',
              isNeo ? 'rounded' : 'rounded-sm',
              isSelected
                ? isNeo
                  ? 'bg-accent border border-black font-bold text-black dark:border-white'
                  : 'bg-accent/20 text-accent-deep dark:text-accent font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            <Icon className="h-4 w-4" />
          </button>
        );
      })}
    </div>
  );
}

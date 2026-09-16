'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { Home, Search, Bell, User } from 'lucide-react';

export function BottomNavMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [active, setActive] = useState(0);
  const isNeo = preset === 'neobrutalism';

  const items = [
    { icon: Home, label: 'Home' },
    { icon: Search, label: 'Search' },
    { icon: Bell, label: 'Alerts' },
    { icon: User, label: 'Profile' },
  ];

  return (
    <div
      data-testid="mock-bottom-nav"
      className={cn(
        'flex w-full max-w-[240px] items-center justify-around p-2 select-none',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[3px_3px_0px_0px_#000] dark:border-white dark:shadow-[3px_3px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-xl border shadow-sm'
      )}
    >
      {items.map(({ icon: Icon, label }, idx) => {
        const isSelected = active === idx;
        return (
          <button
            key={label}
            type="button"
            onClick={() => setActive(idx)}
            aria-label={label}
            className={cn(
              'flex flex-col items-center gap-0.5 p-1 transition-all',
              isSelected
                ? isNeo
                  ? 'font-bold text-black dark:text-white'
                  : 'text-accent'
                : 'text-muted hover:text-foreground'
            )}
          >
            <Icon className="h-4 w-4" />
            <span className="font-mono text-[9px]">{label}</span>
          </button>
        );
      })}
    </div>
  );
}

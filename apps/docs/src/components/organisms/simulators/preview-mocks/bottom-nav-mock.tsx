'use client';

import { useState } from 'react';
import { Home, Package, Search, User } from 'lucide-react';
import { cn } from '@/lib/cn';
import { raised } from './mock-styles';

const items = [
  { icon: Home, label: 'Home' },
  { icon: Search, label: 'Search' },
  { icon: Package, label: 'Orders' },
  { icon: User, label: 'Account' },
];

export function BottomNavMock() {
  const [active, setActive] = useState(2);

  return (
    <nav
      aria-label="App"
      data-testid="mock-bottom-nav"
      className={cn(
        raised,
        'flex w-full max-w-64 items-center justify-around p-1.5'
      )}
    >
      {items.map(({ icon: Icon, label }, idx) => {
        const selected = active === idx;
        return (
          <button
            key={label}
            type="button"
            onClick={() => setActive(idx)}
            aria-current={selected ? 'page' : undefined}
            className={cn(
              'flex flex-col items-center gap-0.5 rounded-(--just-radius-sm) px-2 py-1',
              selected
                ? 'text-foreground font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            <Icon className="h-4 w-4" aria-hidden="true" />
            <span className="text-xs">{label}</span>
          </button>
        );
      })}
    </nav>
  );
}

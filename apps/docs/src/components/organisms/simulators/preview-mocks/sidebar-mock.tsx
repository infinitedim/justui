'use client';

import { useState } from 'react';
import { ChevronLeft, LayoutList, Package, Settings } from 'lucide-react';
import { cn } from '@/lib/cn';
import { focusRing, raised } from './mock-styles';

const items = [
  { icon: Package, label: 'Orders', active: true },
  { icon: LayoutList, label: 'Products', active: false },
  { icon: Settings, label: 'Settings', active: false },
];

export function SidebarMock() {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <nav
      aria-label="Store admin"
      data-testid="mock-sidebar"
      className={cn(raised, 'p-2', collapsed ? 'w-14' : 'w-48')}
    >
      <div className="mb-1 flex items-center justify-between px-1 pb-1">
        {!collapsed ? (
          <span className="text-sm font-semibold">Store admin</span>
        ) : null}
        <button
          type="button"
          onClick={() => setCollapsed((c) => !c)}
          aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
          aria-expanded={!collapsed}
          className={cn(
            'text-secondary hover:text-foreground ml-auto p-1',
            focusRing
          )}
        >
          <ChevronLeft
            className={cn('h-4 w-4', collapsed && 'rotate-180')}
            aria-hidden="true"
          />
        </button>
      </div>
      <ul className="space-y-0.5">
        {items.map(({ icon: Icon, label, active }) => (
          <li
            key={label}
            aria-current={active ? 'page' : undefined}
            className={cn(
              'flex items-center gap-2 rounded-(--just-radius-sm) px-2 py-1.5 text-sm',
              active
                ? 'bg-accent text-accent-foreground font-medium'
                : 'text-secondary'
            )}
          >
            <Icon className="h-4 w-4 shrink-0" aria-hidden="true" />
            {!collapsed ? <span>{label}</span> : null}
          </li>
        ))}
      </ul>
    </nav>
  );
}

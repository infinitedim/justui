'use client';

import { useState } from 'react';
import {
  Layers,
  LayoutDashboard,
  PanelLeftClose,
  PanelLeftOpen,
  Users,
} from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const ICONS = {
  pipeline: Layers,
  contacts: Users,
  reports: LayoutDashboard,
} as const;

export function SidebarMock() {
  const { crm } = useCatalogI18n();
  const [collapsed, setCollapsed] = useState(false);
  const [active, setActive] = useState('pipeline');

  return (
    <nav
      aria-label={crm.sidebar.label}
      data-testid="mock-sidebar"
      className={cn(
        surface,
        'flex flex-col gap-0.5 p-1.5 transition-[width]',
        collapsed ? 'w-12' : 'w-44'
      )}
    >
      <button
        type="button"
        onClick={() => setCollapsed((c) => !c)}
        aria-label={collapsed ? crm.sidebar.expand : crm.sidebar.collapse}
        aria-expanded={!collapsed}
        className={cn(
          focusRing,
          'text-muted hover:text-foreground flex h-8 w-8 items-center justify-center self-end rounded-(--just-radius-sm)'
        )}
      >
        {collapsed ? (
          <PanelLeftOpen className="h-4 w-4" aria-hidden="true" />
        ) : (
          <PanelLeftClose className="h-4 w-4" aria-hidden="true" />
        )}
      </button>
      {crm.sidebar.items.map((item) => {
        const Icon = ICONS[item.id as keyof typeof ICONS] ?? Layers;
        const current = item.id === active;
        return (
          <button
            key={item.id}
            type="button"
            onClick={() => setActive(item.id)}
            aria-current={current ? 'page' : undefined}
            aria-label={collapsed ? item.label : undefined}
            title={collapsed ? item.label : undefined}
            className={cn(
              focusRing,
              'flex h-8 items-center gap-2 rounded-(--just-radius-sm) px-2 text-sm',
              current
                ? 'bg-accent text-accent-foreground font-medium'
                : 'text-muted hover:text-foreground'
            )}
          >
            <Icon className="h-4 w-4 shrink-0" aria-hidden="true" />
            {collapsed ? null : <span className="truncate">{item.label}</span>}
          </button>
        );
      })}
    </nav>
  );
}

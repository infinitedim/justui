'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { LayoutDashboard, Settings, Layers, ChevronRight } from 'lucide-react';

export function SidebarMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [collapsed, setCollapsed] = useState(false);
  const isNeo = preset === 'neobrutalism';

  return (
    <div
      data-testid="mock-sidebar"
      className={cn(
        'p-2 font-mono text-xs transition-all select-none',
        collapsed ? 'w-14' : 'w-48',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[3px_3px_0px_0px_#000] dark:border-white dark:shadow-[3px_3px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-lg border shadow-sm'
      )}
    >
      <div className="border-border mb-2 flex items-center justify-between border-b pb-2">
        {!collapsed ? (
          <span className="text-[11px] font-bold">JustUI Core</span>
        ) : null}
        <button
          type="button"
          onClick={() => setCollapsed(!collapsed)}
          aria-label="Toggle Sidebar"
          className="hover:text-accent ml-auto p-1"
        >
          <ChevronRight
            className={cn(
              'h-3.5 w-3.5 transition-transform',
              !collapsed && 'rotate-180'
            )}
          />
        </button>
      </div>

      <div className="space-y-1">
        <div className="bg-accent/15 text-accent-deep dark:text-accent flex items-center gap-2 rounded p-1.5 font-medium">
          <LayoutDashboard className="h-3.5 w-3.5 shrink-0" />
          {!collapsed ? <span className="text-[11px]">Dashboard</span> : null}
        </div>
        <div className="text-muted hover:text-foreground flex items-center gap-2 rounded p-1.5">
          <Layers className="h-3.5 w-3.5 shrink-0" />
          {!collapsed ? <span className="text-[11px]">Components</span> : null}
        </div>
        <div className="text-muted hover:text-foreground flex items-center gap-2 rounded p-1.5">
          <Settings className="h-3.5 w-3.5 shrink-0" />
          {!collapsed ? <span className="text-[11px]">Settings</span> : null}
        </div>
      </div>
    </div>
  );
}

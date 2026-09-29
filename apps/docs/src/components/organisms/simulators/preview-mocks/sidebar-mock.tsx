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
          ? 'bg-surface rounded-none border-[2.5px] border-black shadow-[4px_4px_0px_0px_#000] dark:border-white dark:shadow-[4px_4px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-lg border shadow-sm'
      )}
    >
      <div
        className={cn(
          'mb-2 flex items-center justify-between pb-2',
          isNeo
            ? 'border-b-[2.5px] border-black dark:border-white'
            : 'border-border border-b'
        )}
      >
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
        <div
          className={cn(
            'flex items-center gap-2 p-1.5 font-medium',
            isNeo
              ? 'bg-accent text-black font-bold border-[2.5px] border-black dark:border-white rounded-none'
              : 'bg-accent/15 text-accent-deep dark:text-accent rounded'
          )}
        >
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

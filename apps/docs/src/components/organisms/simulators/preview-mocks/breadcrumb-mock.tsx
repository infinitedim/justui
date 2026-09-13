'use client';

import React from 'react';
import { cn } from '@/lib/cn';
import { ChevronRight } from 'lucide-react';

export function BreadcrumbMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const isNeo = preset === 'neobrutalism';

  return (
    <nav
      aria-label="Breadcrumb"
      data-testid="mock-breadcrumb"
      className={cn(
        'flex items-center gap-1.5 p-2 font-mono text-xs select-none',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-md border'
      )}
    >
      <span className="text-muted hover:text-foreground cursor-pointer">
        Home
      </span>
      <ChevronRight className="text-muted h-3.5 w-3.5" />
      <span className="text-muted hover:text-foreground cursor-pointer">
        Docs
      </span>
      <ChevronRight className="text-muted h-3.5 w-3.5" />
      <span className="text-foreground font-bold">Button</span>
    </nav>
  );
}

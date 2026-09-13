'use client';

import React from 'react';
import { cn } from '@/lib/cn';

export function SkeletonMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const isNeo = preset === 'neobrutalism';

  return (
    <div data-testid="mock-skeleton" className="w-full max-w-55 space-y-2.5">
      <div className="flex items-center gap-2.5">
        <div
          className={cn(
            'h-9 w-9 animate-pulse transition-all',
            isNeo
              ? 'bg-surface-muted rounded-md border-2 border-black dark:border-white'
              : 'bg-border rounded-full'
          )}
        />
        <div className="flex-1 space-y-1">
          <div
            className={cn(
              'h-3.5 w-3/4 animate-pulse',
              isNeo
                ? 'bg-surface-muted border border-black dark:border-white'
                : 'bg-border rounded'
            )}
          />
          <div
            className={cn(
              'h-2.5 w-1/2 animate-pulse',
              isNeo
                ? 'bg-surface-muted border border-black dark:border-white'
                : 'bg-border/70 rounded'
            )}
          />
        </div>
      </div>
      <div
        className={cn(
          'h-8 w-full animate-pulse',
          isNeo
            ? 'bg-surface-muted rounded-md border-2 border-black dark:border-white'
            : 'bg-border/60 rounded-md'
        )}
      />
    </div>
  );
}

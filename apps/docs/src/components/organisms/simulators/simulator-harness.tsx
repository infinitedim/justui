'use client';

import React from 'react';
import { cn } from '@/lib/cn';

export interface SimulatorHarnessProps {
  preset?: 'default' | 'neobrutalism';
  children: React.ReactNode;
  className?: string;
  badge?: string;
}

export function SimulatorHarness({
  preset = 'default',
  children,
  className,
  badge,
}: SimulatorHarnessProps) {
  const isNeo = preset === 'neobrutalism';

  return (
    <div
      data-testid="simulator-harness"
      data-preset={preset}
      className={cn(
        'relative flex h-44 w-full items-center justify-center overflow-hidden p-4 transition-all select-none',
        'bg-surface/50 bg-[radial-gradient(var(--color-border)_1px,transparent_1px)] bg-size-[14px_14px]',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[3px_3px_0px_0px_#000] dark:border-white dark:shadow-[3px_3px_0px_0px_#fff]'
          : 'border-border/70 bg-surface/30 rounded-lg border',
        className
      )}
    >
      {badge ? (
        <span
          className={cn(
            'absolute top-2 right-2 px-1.5 py-0.5 font-mono text-[10px] tracking-wider uppercase',
            isNeo
              ? 'bg-accent border border-black font-bold text-black dark:border-white'
              : 'bg-surface-muted border-border text-muted rounded border'
          )}
        >
          {badge}
        </span>
      ) : null}
      <div className="flex w-full max-w-70 items-center justify-center">
        {children}
      </div>
    </div>
  );
}

'use client';

import React from 'react';
import { cn } from '@/lib/cn';

export interface SimulatorHarnessProps {
  preset?: 'default' | 'neobrutalism';
  children: React.ReactNode;
  className?: string;
}

/**
 * Preview frame for one catalog mock. The preset is applied as a token
 * scope class (each preset class is a complete --just-* set), so neither the
 * frame nor the mock inside needs to know which preset is active.
 */
export function SimulatorHarness({
  preset = 'default',
  children,
  className,
}: SimulatorHarnessProps) {
  return (
    <div
      data-testid="simulator-harness"
      data-preset={preset}
      className={cn(
        preset === 'neobrutalism' ? 'theme-neobrutalism' : 'preset-default',
        'bg-background text-foreground relative flex h-44 w-full items-center justify-center overflow-visible p-4 select-none focus-within:z-20',
        className
      )}
    >
      <div className="flex w-full max-w-70 items-center justify-center">
        {children}
      </div>
    </div>
  );
}

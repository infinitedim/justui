import type { ReactNode } from 'react';
import { cn } from '@/lib/cn';

export interface SimulatorHarnessProps {
  children: ReactNode;
  className?: string;
}

/**
 * Plain stage for one preview mock. The background is the page background
 * token, so the component is judged against the surface it will sit on.
 */
export function SimulatorHarness({
  children,
  className,
}: SimulatorHarnessProps) {
  return (
    <div
      data-testid="simulator-harness"
      className={cn(
        'bg-background relative flex h-48 w-full items-center justify-center p-4 focus-within:z-20',
        className
      )}
    >
      <div className="flex w-full max-w-72 items-center justify-center">
        {children}
      </div>
    </div>
  );
}

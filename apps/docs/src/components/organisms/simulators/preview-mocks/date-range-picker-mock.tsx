'use client';

import React from 'react';
import { cn } from '@/lib/cn';
import { CalendarRange } from 'lucide-react';

export function DateRangePickerMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="w-full max-w-[220px] font-mono text-xs select-none">
      <div
        data-testid="mock-date-range-picker"
        className={cn(
          'flex cursor-pointer items-center gap-2 p-2 transition-all',
          isNeo
            ? 'bg-surface rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
            : 'border-border bg-surface rounded-md border'
        )}
      >
        <CalendarRange className="text-muted h-4 w-4 shrink-0" />
        <span className="text-foreground text-[11px] font-medium">
          Sep 01 - Sep 15
        </span>
      </div>
      <p className="text-muted mt-1.5 text-center text-[10px]">
        14 Days Selected
      </p>
    </div>
  );
}

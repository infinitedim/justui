'use client';

import React from 'react';
import { cn } from '@/lib/cn';
import { Calendar } from 'lucide-react';

export function DatePickerMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const date = '2026-09-13';
  const isNeo = preset === 'neobrutalism';

  return (
    <div className="w-full max-w-50 font-mono text-xs select-none">
      <div
        data-testid="mock-date-picker"
        className={cn(
          'flex cursor-pointer items-center justify-between p-2 transition-all',
          isNeo
            ? 'bg-surface rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
            : 'border-border bg-surface rounded-md border'
        )}
      >
        <div className="flex items-center gap-2">
          <Calendar className="text-muted h-4 w-4" />
          <span className="text-foreground font-medium">{date}</span>
        </div>
      </div>
      <p className="text-muted mt-1.5 text-center text-[10px]">ISO-8601 UTC</p>
    </div>
  );
}

'use client';

import React, { useState } from 'react';
import { cn } from '@/lib/cn';
import { Clock } from 'lucide-react';

export function TimePickerMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [period, setPeriod] = useState<'AM' | 'PM'>('PM');
  const isNeo = preset === 'neobrutalism';

  return (
    <div
      data-testid="mock-time-picker"
      className={cn(
        'inline-flex items-center gap-2 p-2 font-mono text-xs select-none',
        isNeo
          ? 'bg-surface rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
          : 'border-border bg-surface rounded-md border'
      )}
    >
      <Clock className="text-muted h-4 w-4" />
      <span className="text-foreground font-bold">18:30</span>
      <button
        type="button"
        onClick={() => setPeriod(period === 'AM' ? 'PM' : 'AM')}
        className={cn(
          'px-1.5 py-0.5 text-[10px] font-bold transition-all',
          isNeo
            ? 'bg-accent border border-black text-black dark:border-white'
            : 'bg-surface-muted text-accent rounded'
        )}
      >
        {period}
      </button>
    </div>
  );
}

'use client';

import React from 'react';
import { cn } from '@/lib/cn';

export function AvatarGroupMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const isNeo = preset === 'neobrutalism';
  const users = ['JU', 'FL', 'DT'];

  return (
    <div
      data-testid="mock-avatar-group"
      className="flex items-center select-none"
    >
      {users.map((initials, i) => (
        <div
          key={initials}
          className={cn(
            'flex h-9 w-9 items-center justify-center font-mono text-xs font-bold transition-all',
            i > 0 && '-ml-2.5',
            isNeo
              ? 'bg-surface text-foreground rounded-md border-2 border-black shadow-[2px_2px_0px_0px_#000] dark:border-white dark:shadow-[2px_2px_0px_0px_#fff]'
              : 'border-surface bg-foreground text-background rounded-full border-2 shadow-sm'
          )}
        >
          {initials}
        </div>
      ))}
      <div
        className={cn(
          '-ml-2.5 flex h-9 w-9 items-center justify-center font-mono text-[10px] font-bold transition-all',
          isNeo
            ? 'bg-accent rounded-md border-2 border-black text-black shadow-[2px_2px_0px_0px_#000] dark:border-white'
            : 'border-surface bg-surface-muted text-muted rounded-full border-2 shadow-sm'
        )}
      >
        +30
      </div>
    </div>
  );
}

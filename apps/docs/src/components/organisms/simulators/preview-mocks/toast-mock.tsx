'use client';

import React, { useState, useRef, useEffect } from 'react';
import { cn } from '@/lib/cn';
import { Bell, CheckCircle2 } from 'lucide-react';

export function ToastMock({
  preset = 'default',
}: {
  preset?: 'default' | 'neobrutalism';
}) {
  const [show, setShow] = useState(false);
  const [isExiting, setIsExiting] = useState(false);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const exitTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const isNeo = preset === 'neobrutalism';

  const clearTimers = () => {
    if (timerRef.current) clearTimeout(timerRef.current);
    if (exitTimerRef.current) clearTimeout(exitTimerRef.current);
  };

  const triggerToast = () => {
    clearTimers();
    setIsExiting(false);
    setShow(true);

    timerRef.current = setTimeout(() => {
      setIsExiting(true);
      exitTimerRef.current = setTimeout(() => {
        setShow(false);
        setIsExiting(false);
      }, 150);
    }, 2400);
  };

  useEffect(() => {
    return () => clearTimers();
  }, []);

  return (
    <div className="relative flex w-full flex-col items-center justify-center">
      <button
        type="button"
        onClick={triggerToast}
        data-testid="mock-toast-trigger"
        className={cn(
          'flex items-center gap-2 px-3 py-1.5 font-mono text-xs transition-all select-none',
          isNeo
            ? 'bg-surface text-foreground rounded-md border-2 border-black shadow-[2.5px_2.5px_0px_0px_#000] active:translate-x-0.5 active:translate-y-0.5 dark:border-white dark:shadow-[2.5px_2.5px_0px_0px_#fff]'
            : 'border-border bg-surface text-foreground hover:border-accent rounded-md border'
        )}
      >
        <Bell className="h-3.5 w-3.5" />
        <span>Trigger Toast</span>
      </button>

      {show ? (
        <div
          data-testid="mock-toast-popup"
          className={cn(
            'absolute -top-2 flex items-center gap-2 px-3 py-1.5 font-mono text-[11px] select-none',
            'motion-reduce:animate-none',
            isExiting ? 'animate-toast-exit' : 'animate-toast-enter',
            isNeo
              ? 'bg-accent rounded-md border-2 border-black font-bold text-black shadow-[3px_3px_0px_0px_#000] dark:border-white'
              : 'border-border bg-foreground text-background rounded-lg border shadow-lg'
          )}
        >
          <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500" />
          <span>Package installed!</span>
        </div>
      ) : null}
    </div>
  );
}

'use client';

import { useState, useRef, useEffect } from 'react';
import { CheckCircle2 } from 'lucide-react';
import { cn } from '@/lib/cn';
import { outlineButton, raised } from './mock-styles';

export function ToastMock() {
  const [show, setShow] = useState(false);
  const [isExiting, setIsExiting] = useState(false);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const exitTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

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
    }, 4000);
  };

  useEffect(() => clearTimers, []);

  return (
    <div className="relative flex w-full flex-col items-center justify-center">
      <button
        type="button"
        onClick={triggerToast}
        data-testid="mock-toast-trigger"
        className={outlineButton}
      >
        Mark as shipped
      </button>

      {show ? (
        <div
          role="status"
          data-testid="mock-toast-popup"
          className={cn(
            raised,
            'absolute -top-12 flex items-center gap-2 px-3 py-2 text-sm whitespace-nowrap',
            'motion-reduce:animate-none',
            isExiting ? 'animate-toast-exit' : 'animate-toast-enter'
          )}
        >
          <CheckCircle2 className="text-success h-4 w-4" aria-hidden="true" />
          <span>Order #1042 shipped</span>
        </div>
      ) : null}
    </div>
  );
}

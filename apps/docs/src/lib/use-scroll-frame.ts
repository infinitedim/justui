'use client';

import { useEffectEvent, useLayoutEffect } from 'react';

/**
 * Runs `onFrame` at most once per animation frame while `enabled`: once
 * before the first paint, then on every scroll and resize. The callback
 * reads layout and writes inline styles; it never sets React state.
 */
export function useScrollFrame(enabled: boolean, onFrame: () => void): void {
  const frame = useEffectEvent(onFrame);
  useLayoutEffect(() => {
    if (!enabled) return;
    let pending = 0;
    const schedule = () => {
      if (pending !== 0) return;
      pending = requestAnimationFrame(() => {
        pending = 0;
        frame();
      });
    };
    frame();
    window.addEventListener('scroll', schedule, { passive: true });
    window.addEventListener('resize', schedule);
    return () => {
      cancelAnimationFrame(pending);
      window.removeEventListener('scroll', schedule);
      window.removeEventListener('resize', schedule);
    };
  }, [enabled]);
}

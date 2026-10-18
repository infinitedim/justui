'use client';

import { useSyncExternalStore } from 'react';
import { useTheme } from 'next-themes';

function noopSubscribe(): () => void {
  return () => {};
}

export interface ThemeSwitch {
  /** False until mounted, so the server and first client render agree. */
  isDark: boolean;
  toggle: () => void;
}

/**
 * Light/dark switch for the Ink and Paper pages. The page-curl transition
 * is attached in `src/lib/page-turn` (PRD step S11); until then the theme
 * changes immediately.
 */
export function useThemeSwitch(): ThemeSwitch {
  const { resolvedTheme, setTheme } = useTheme();
  const mounted = useSyncExternalStore(
    noopSubscribe,
    () => true,
    () => false
  );
  const isDark = mounted && resolvedTheme === 'dark';
  return {
    isDark,
    toggle: () => setTheme(isDark ? 'light' : 'dark'),
  };
}

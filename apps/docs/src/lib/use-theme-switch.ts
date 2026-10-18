'use client';

import { useEffect, useSyncExternalStore } from 'react';
import { useTheme } from 'next-themes';
import { prefersReducedMotion } from '@/lib/use-reduced-motion';

function noopSubscribe(): () => void {
  return () => {};
}

/** How long to wait for next-themes to flip the html class. */
const COMMIT_TIMEOUT_MS = 500;

export interface ThemeSwitch {
  /** False until mounted, so the server and first client render agree. */
  isDark: boolean;
  toggle: () => void;
}

/**
 * Applies the theme and resolves once the html class has changed and the
 * new theme has painted (or after a short timeout).
 */
export function commitTheme(apply: () => void, dark: boolean): Promise<void> {
  const html = document.documentElement;
  return new Promise((resolve) => {
    let settled = false;
    const done = () => {
      if (settled) return;
      settled = true;
      observer.disconnect();
      window.clearTimeout(timer);
      requestAnimationFrame(() => requestAnimationFrame(() => resolve()));
    };
    const observer = new MutationObserver(() => {
      if (html.classList.contains('dark') === dark) done();
    });
    observer.observe(html, { attributes: true, attributeFilter: ['class'] });
    const timer = window.setTimeout(done, COMMIT_TIMEOUT_MS);
    apply();
    if (html.classList.contains('dark') === dark) done();
  });
}

/** Reads a CSS custom property off the page root. */
function readToken(root: HTMLElement, name: string): string {
  return getComputedStyle(root).getPropertyValue(name).trim();
}

/**
 * Light/dark switch for the Ink and Paper pages: the page curl from
 * `src/lib/page-turn` (loaded on first use). Pages without a
 * `[data-page-root]` switch immediately.
 */
export function useThemeSwitch(): ThemeSwitch {
  const { resolvedTheme, setTheme } = useTheme();
  const mounted = useSyncExternalStore(
    noopSubscribe,
    () => true,
    () => false
  );
  const isDark = mounted && resolvedTheme === 'dark';

  // Load the turn and inline the fonts while the page is idle.
  useEffect(() => {
    const warm = () => {
      void import('@/lib/page-turn').then((turn) => turn.warmPageTurn());
    };
    const timer = window.setTimeout(warm, 2000);
    return () => window.clearTimeout(timer);
  }, []);

  const toggle = () => {
    const next = isDark ? 'light' : 'dark';
    const apply = () => setTheme(next);
    const root = document.querySelector<HTMLElement>('[data-page-root]');
    if (!root) {
      apply();
      return;
    }
    void import('@/lib/page-turn')
      .then(({ pageTurn }) =>
        pageTurn({
          root,
          paper: readToken(root, '--ip-canvas'),
          paperNext: readToken(root, '--ip-canvas-opposite'),
          dark: isDark,
          dir: isDark ? -1 : 1,
          reverse: isDark,
          reduced: prefersReducedMotion(),
          commit: () => commitTheme(apply, !isDark),
        })
      )
      .catch(apply);
  };

  return { isDark, toggle };
}

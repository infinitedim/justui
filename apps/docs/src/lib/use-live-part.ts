'use client';

import { useEffect, useRef, useState, type RefObject } from 'react';
import {
  canRunFlutter,
  mountView,
  type LiveView,
  type ViewConfig,
} from '@/lib/flutter-bridge';

/** Start loading a little before the part scrolls into view. */
const NEAR_MARGIN = '200px';
/** Keep a view that left the viewport this long (scrolling back is common). */
const REMOVE_DELAY_MS = 3000;

/** What a view shows; the live view is shown only when it matches. */
function configKey(config: ViewConfig): string {
  return JSON.stringify([
    config.preset,
    config.theme,
    config.locale,
    config.props ?? null,
  ]);
}

function onIdle(run: () => void): void {
  // Safari has no requestIdleCallback (it never loads Flutter, but keep the
  // hook safe everywhere).
  if (typeof window.requestIdleCallback === 'function') {
    window.requestIdleCallback(run, { timeout: 1500 });
  } else {
    globalThis.setTimeout(run, 200);
  }
}

/**
 * Mounts a Flutter view into [host] while [wrapper] is near the viewport
 * and keeps it in sync with [config]. Returns true while the view is
 * mounted and shows the current config; callers show the fallback
 * otherwise. Browsers that cannot run the bundle never load it.
 */
export function useLivePart(
  wrapper: RefObject<HTMLElement | null>,
  host: RefObject<HTMLElement | null>,
  config: ViewConfig
): boolean {
  const [view, setView] = useState<LiveView | null>(null);
  const [shownKey, setShownKey] = useState<string | null>(null);
  const latest = useRef(config);
  const key = configKey(config);
  const scene = config.scene;

  useEffect(() => {
    latest.current = config;
  });

  useEffect(() => {
    const box = wrapper.current;
    const target = host.current;
    if (!box || !target || !canRunFlutter()) return undefined;
    let current: LiveView | null = null;
    let mounting = false;
    let disposed = false;
    let removeTimer = 0;
    const mount = () => {
      if (current || mounting || disposed) return;
      mounting = true;
      const mountedWith = latest.current;
      void (async () => {
        const result = await mountView(target, mountedWith);
        mounting = false;
        if (!result.ok) return;
        if (disposed) {
          result.value.remove();
          return;
        }
        current = result.value;
        setView(current);
        setShownKey(configKey(mountedWith));
      })();
    };
    const unmount = () => {
      current?.remove();
      current = null;
      setView(null);
      setShownKey(null);
    };
    const observer = new IntersectionObserver(
      (entries) => {
        const near = entries.some((entry) => entry.isIntersecting);
        window.clearTimeout(removeTimer);
        if (near) onIdle(mount);
        else if (current)
          removeTimer = window.setTimeout(unmount, REMOVE_DELAY_MS);
      },
      { rootMargin: NEAR_MARGIN }
    );
    observer.observe(box);
    return () => {
      disposed = true;
      observer.disconnect();
      window.clearTimeout(removeTimer);
      current?.remove();
    };
  }, [wrapper, host, scene]);

  useEffect(() => {
    if (!view || shownKey === key) return undefined;
    let stale = false;
    const { preset, theme, locale, strings, props } = latest.current;
    void (async () => {
      await view.update({ preset, theme, locale, strings, props });
      if (!stale) setShownKey(key);
    })();
    return () => {
      stale = true;
    };
  }, [view, key, shownKey]);

  return view !== null && shownKey === key;
}

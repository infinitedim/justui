'use client';

import { useSyncExternalStore } from 'react';
import { SWITCHING } from '@/lib/page-turn/shared';

function subscribe(onChange: () => void): () => void {
  const observer = new MutationObserver(onChange);
  observer.observe(document.documentElement, {
    attributes: true,
    attributeFilter: [SWITCHING],
  });
  return () => observer.disconnect();
}

/**
 * True while the theme switch (page curl) runs. Live Flutter parts show
 * their React fallback meanwhile: the canvas cannot be rasterized into the
 * curl, and it would show the old theme until Flutter repaints.
 */
export function useThemeSwitching(): boolean {
  return useSyncExternalStore(
    subscribe,
    () => document.documentElement.hasAttribute(SWITCHING),
    () => false
  );
}

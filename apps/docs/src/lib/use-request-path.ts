'use client';

import { useSyncExternalStore } from 'react';

function subscribe(): () => void {
  // The path of a rendered page never changes in place; a navigation
  // unmounts the page instead.
  return () => {};
}

/**
 * The path the visitor asked for, read from `location`. The 404 is one
 * static page for every unknown URL, so the server cannot know it: this
 * returns '' during the prerender and hydration, then the real path.
 */
export function useRequestPath(): string {
  return useSyncExternalStore(
    subscribe,
    () => window.location.pathname,
    () => ''
  );
}

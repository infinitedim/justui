import { useCallback, useRef } from 'react';
import type { KeyboardEvent } from 'react';

const KEY_STEP: Record<string, number> = {
  ArrowRight: 1,
  ArrowDown: 1,
  ArrowLeft: -1,
  ArrowUp: -1,
};

/**
 * Keyboard support for a WAI-ARIA tablist with automatic activation:
 * ArrowLeft/ArrowRight (and Up/Down) move to the previous/next tab with
 * wrap-around, Home/End jump to the first/last tab. Focus follows the
 * selection so only the active tab needs `tabIndex={0}` (roving tabindex).
 */
export function useRovingTabs<T extends string>(
  ids: readonly T[],
  active: T,
  onSelect: (id: T) => void
) {
  const tabRefs = useRef(new Map<T, HTMLButtonElement | null>());

  const registerTab = useCallback(
    (id: T) => (node: HTMLButtonElement | null) => {
      tabRefs.current.set(id, node);
    },
    []
  );

  const onKeyDown = useCallback(
    (event: KeyboardEvent<HTMLElement>) => {
      const current = ids.indexOf(active);
      let next: number | undefined;
      if (event.key === 'Home') next = 0;
      else if (event.key === 'End') next = ids.length - 1;
      else if (event.key in KEY_STEP) {
        next = (current + (KEY_STEP[event.key] ?? 0) + ids.length) % ids.length;
      }
      if (next === undefined) return;

      event.preventDefault();
      const id = ids[next];
      if (id === undefined) return;
      onSelect(id);
      tabRefs.current.get(id)?.focus();
    },
    [ids, active, onSelect]
  );

  return { registerTab, onKeyDown };
}

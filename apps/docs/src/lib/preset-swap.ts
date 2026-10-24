'use client';

import { detachClone, showFallbacksInClone } from '@/lib/page-turn/shared';
import { prefersReducedMotion } from '@/lib/use-reduced-motion';

const EASE = 'cubic-bezier(0.16, 1, 0.3, 1)';
const DURATION = 520;

/**
 * Cross-dissolves every visible preset stage (`[data-pbox]`) while `apply`
 * switches the preset (handoff swapPreset). Each ghost is a clone placed in
 * its own `.ink-paper` wrapper on `document.body`, outside the React tree,
 * and removed when its animation ends.
 */
export function animatePresetSwap(apply: () => void): void {
  if (prefersReducedMotion() || typeof document === 'undefined') {
    apply();
    return;
  }
  const viewport = window.innerHeight;
  const pairs: Array<{ box: HTMLElement; ghost: HTMLElement }> = [];
  for (const box of document.querySelectorAll<HTMLElement>('[data-pbox]')) {
    const rect = box.getBoundingClientRect();
    if (rect.bottom < 0 || rect.top > viewport || !box.animate) continue;
    const ghost = document.createElement('div');
    ghost.className = 'ink-paper';
    ghost.setAttribute('aria-hidden', 'true');
    ghost.inert = true;
    Object.assign(ghost.style, {
      position: 'absolute',
      left: `${rect.left + window.scrollX}px`,
      top: `${rect.top + window.scrollY}px`,
      width: `${rect.width}px`,
      height: `${rect.height}px`,
      pointerEvents: 'none',
      zIndex: '5',
    });
    const clone = box.cloneNode(true);
    if (clone instanceof HTMLElement) {
      clone.removeAttribute('data-pbox');
      detachClone(clone);
      showFallbacksInClone(clone);
    }
    ghost.append(clone);
    document.body.append(ghost);
    pairs.push({ box, ghost });
  }
  apply();
  requestAnimationFrame(() => {
    for (const { box, ghost } of pairs) {
      const options = { duration: DURATION, easing: EASE };
      ghost.animate(
        [
          { opacity: 1, filter: 'blur(0px)', transform: 'scale(1)' },
          { opacity: 0, filter: 'blur(3px)', transform: 'scale(0.985)' },
        ],
        { ...options, fill: 'forwards' }
      ).onfinish = () => ghost.remove();
      box.animate(
        [
          { opacity: 0.4, filter: 'blur(3px)', transform: 'scale(1.012)' },
          { opacity: 1, filter: 'blur(0px)', transform: 'scale(1)' },
        ],
        options
      );
    }
  });
}

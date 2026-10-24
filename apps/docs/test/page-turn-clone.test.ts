import { describe, expect, it } from 'vitest';
import { showFallbacksInClone } from '@/lib/page-turn/shared';

describe('showFallbacksInClone', () => {
  it('shows the React fallback and empties the Flutter host', () => {
    const page = document.createElement('div');
    page.innerHTML = `
      <div data-live-part="button" data-state="live">
        <div><button>Save changes</button></div>
        <div data-live-host><flutter-view></flutter-view></div>
      </div>`;
    showFallbacksInClone(page);
    const part = page.querySelector('[data-live-part]');
    expect(part?.getAttribute('data-state')).toBe('fallback');
    expect(page.querySelector('[data-live-host]')?.childElementCount).toBe(0);
    expect(page.querySelector('button')).not.toBeNull();
  });
});

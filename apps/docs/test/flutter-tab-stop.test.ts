import { afterEach, describe, expect, it } from 'vitest';
import { keepEmptyViewOutOfTabOrder } from '@/lib/flutter-bridge/tab-stop';

/** A host as the engine builds it: a flutter-view the keyboard can reach. */
function hostWith(semantics: string): HTMLElement {
  const host = document.createElement('div');
  host.innerHTML = `<flutter-view tabindex="0"><flt-semantics-host>${semantics}</flt-semantics-host></flutter-view>`;
  document.body.append(host);
  return host;
}

const viewOf = (host: HTMLElement) => host.querySelector('flutter-view');
const settle = () => new Promise((resolve) => setTimeout(resolve, 0));

afterEach(() => {
  document.body.innerHTML = '';
});

describe('keepEmptyViewOutOfTabOrder', () => {
  it('takes a view with no controls out of the Tab order', () => {
    const host = hostWith('<flt-semantics role="text">Draft</flt-semantics>');
    const stop = keepEmptyViewOutOfTabOrder(host);
    expect(viewOf(host)?.getAttribute('tabindex')).toBe('-1');
    stop();
  });

  it('leaves a view with a control to the engine', () => {
    const host = hostWith(
      '<flt-semantics tabindex="0" role="button">Save</flt-semantics>'
    );
    const stop = keepEmptyViewOutOfTabOrder(host);
    expect(viewOf(host)?.getAttribute('tabindex')).toBe('0');
    stop();
  });

  it('treats text fields and sliders as controls', () => {
    for (const control of ['<input>', '<textarea></textarea>']) {
      const host = hostWith(control);
      const stop = keepEmptyViewOutOfTabOrder(host);
      expect(viewOf(host)?.getAttribute('tabindex')).toBe('0');
      stop();
    }
  });

  it('keeps it out when the engine makes it reachable again', async () => {
    const host = hostWith('');
    const stop = keepEmptyViewOutOfTabOrder(host);
    viewOf(host)?.setAttribute('tabindex', '0');
    await settle();
    expect(viewOf(host)?.getAttribute('tabindex')).toBe('-1');
    stop();
  });

  it('gives the stop back when a control appears', async () => {
    const host = hostWith('');
    const stop = keepEmptyViewOutOfTabOrder(host);
    host
      .querySelector('flt-semantics-host')
      ?.insertAdjacentHTML('beforeend', '<flt-semantics tabindex="0">');
    await settle();
    expect(viewOf(host)?.getAttribute('tabindex')).toBe('0');
    stop();
  });

  it('stops watching after cleanup', async () => {
    const host = hostWith('');
    keepEmptyViewOutOfTabOrder(host)();
    viewOf(host)?.setAttribute('tabindex', '0');
    await settle();
    expect(viewOf(host)?.getAttribute('tabindex')).toBe('0');
  });
});

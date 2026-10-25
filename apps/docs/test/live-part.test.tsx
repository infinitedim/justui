import { act, render, screen, waitFor } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { installFakeFlutter, removeFakeFlutter } from './support/fake-flutter';

let theme = 'light';
vi.mock('next-themes', () => ({
  useTheme: () => ({ resolvedTheme: theme }),
}));

/** IntersectionObserver that reports every target as visible at once. */
class VisibleObserver {
  constructor(private readonly callback: IntersectionObserverCallback) {}
  observe(target: Element): void {
    setTimeout(() =>
      this.callback(
        [{ isIntersecting: true, target } as IntersectionObserverEntry],
        this as unknown as IntersectionObserver
      )
    );
  }
  disconnect(): void {}
}

async function renderPart() {
  const { LivePart } = await import('@/components/molecules/live-part');
  const { PresetProvider } = await import('@/components/providers');
  const view = render(
    <PresetProvider>
      <LivePart scene="button" lang="en">
        <button type="button">Save changes</button>
      </LivePart>
    </PresetProvider>
  );
  const part = view.container.querySelector('[data-live-part]');
  if (!(part instanceof HTMLElement)) throw new Error('no live part');
  return { ...view, part };
}

describe('LivePart', () => {
  beforeEach(() => {
    vi.resetModules();
    theme = 'light';
    vi.stubGlobal('IntersectionObserver', VisibleObserver);
  });

  afterEach(() => {
    removeFakeFlutter();
    vi.unstubAllGlobals();
    document.documentElement.removeAttribute('data-theme-switching');
  });

  it('keeps the fallback where Flutter cannot run', async () => {
    const { part } = await renderPart();
    expect(part.dataset.state).toBe('fallback');
    expect(screen.getByRole('button', { name: 'Save changes' })).toBeVisible();
    expect(part.querySelector('[data-live-host]')).toHaveAttribute(
      'aria-hidden',
      'true'
    );
  });

  it('swaps to the live view once Flutter painted it', async () => {
    const fake = installFakeFlutter();
    const { part } = await renderPart();
    await waitFor(() => expect(part.dataset.state).toBe('live'));
    expect(fake.initialData[0]).toMatchObject({
      config: {
        scene: 'button',
        preset: 'default',
        theme: 'light',
        locale: 'en',
      },
    });
    const host = part.querySelector('[data-live-host]');
    expect(host).not.toHaveAttribute('aria-hidden');
    expect(host?.previousElementSibling).toHaveAttribute('aria-hidden', 'true');
  });

  it('mounts every view at one fixed size, clipped to the part box', async () => {
    const fake = installFakeFlutter();
    const { part } = await renderPart();
    await waitFor(() => expect(part.dataset.state).toBe('live'));
    const options: unknown = fake.app.addView.mock.calls[0]?.[0];
    const hostElement: unknown =
      typeof options === 'object' && options !== null
        ? Reflect.get(options, 'hostElement')
        : undefined;
    const clip = part.querySelector('[data-live-host]');
    expect(hostElement).toBeInstanceOf(HTMLElement);
    expect(
      clip?.contains(hostElement instanceof Node ? hostElement : null)
    ).toBe(true);
    expect(hostElement).not.toBe(clip);
    expect(clip).toHaveClass('overflow-hidden');
    expect(hostElement).toHaveClass('w-[320px]', 'h-[344px]');
  });

  it('shows the fallback until Flutter applied a new theme', async () => {
    const fake = installFakeFlutter();
    let resolveUpdate: () => void = () => {};
    const { part, rerender } = await renderPart();
    await waitFor(() => expect(part.dataset.state).toBe('live'));
    fake.controller.update.mockReturnValueOnce(
      new Promise<void>((resolve) => (resolveUpdate = resolve))
    );
    theme = 'dark';
    const { LivePart } = await import('@/components/molecules/live-part');
    const { PresetProvider } = await import('@/components/providers');
    rerender(
      <PresetProvider>
        <LivePart scene="button" lang="en">
          <button type="button">Save changes</button>
        </LivePart>
      </PresetProvider>
    );
    await waitFor(() =>
      expect(fake.controller.update).toHaveBeenCalledWith(
        expect.objectContaining({ theme: 'dark' })
      )
    );
    expect(part.dataset.state).toBe('fallback');
    await act(async () => resolveUpdate());
    await waitFor(() => expect(part.dataset.state).toBe('live'));
  });

  it('falls back while the theme switch runs', async () => {
    installFakeFlutter();
    const { part } = await renderPart();
    await waitFor(() => expect(part.dataset.state).toBe('live'));
    act(() =>
      document.documentElement.setAttribute('data-theme-switching', '')
    );
    await waitFor(() => expect(part.dataset.state).toBe('fallback'));
    act(() => document.documentElement.removeAttribute('data-theme-switching'));
    await waitFor(() => expect(part.dataset.state).toBe('live'));
  });
});

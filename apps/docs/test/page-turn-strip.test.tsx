import type { ReactNode } from 'react';
import { render } from '@testing-library/react';
import { afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
import { NotFoundRunner } from '@/components/organisms/not-found-runner';
import { PresetProvider } from '@/components/providers';
import { stripTurn } from '@/lib/page-turn/strip-turn';

vi.mock('next/link', () => ({
  default: ({
    children,
    href,
    prefetch: _prefetch,
    ...props
  }: {
    children: ReactNode;
    href: string | { pathname: string };
    prefetch?: boolean;
  }) => (
    <a href={typeof href === 'string' ? href : href.pathname} {...props}>
      {children}
    </a>
  ),
}));

beforeAll(() => {
  window.matchMedia = vi.fn().mockReturnValue({
    matches: true,
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
  });
  document.elementFromPoint = () => null;
});

afterEach(() => {
  window.history.replaceState(null, '', '/');
});

describe('strip turn', () => {
  it('keeps the live page form state while its copy is on screen', async () => {
    window.history.replaceState(null, '', '/en/radio');
    render(
      <PresetProvider>
        <NotFoundRunner />
      </PresetProvider>
    );
    const root = document.querySelector<HTMLElement>('[data-page-root]');
    if (!root) throw new Error('page root missing');
    const radios = Array.from(
      root.querySelectorAll<HTMLInputElement>('input[type="radio"]')
    );
    const checked = radios.filter((radio) => radio.checked).length;
    expect(checked).toBeGreaterThan(0);

    let layer: Element | null = null;
    await stripTurn({
      root,
      paper: '#fff',
      paperNext: '#000',
      dark: false,
      dir: 1,
      reverse: false,
      reduced: true,
      commit: () => {
        layer = document.body.lastElementChild;
        return Promise.resolve();
      },
    });

    expect(radios.filter((radio) => radio.checked)).toHaveLength(checked);
    expect(layer).toHaveAttribute('inert');
  });
});

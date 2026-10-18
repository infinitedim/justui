import type { ReactNode } from 'react';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
import { metadata } from '@/app/not-found';
import { NotFoundRunner } from '@/components/organisms/not-found-runner';
import { PresetProvider } from '@/components/providers';
import { localeFromPath } from '@/lib/i18n';

vi.mock('next/font/google', () => ({
  IBM_Plex_Mono: () => ({ variable: 'font-mono' }),
  IBM_Plex_Sans: () => ({ variable: 'font-sans' }),
  Plus_Jakarta_Sans: () => ({ variable: 'font-jakarta' }),
}));

vi.mock('next/link', () => ({
  default: ({
    children,
    href,
    ...props
  }: {
    children: ReactNode;
    href: string | { pathname: string; hash?: string };
  }) => (
    <a
      href={
        typeof href === 'string'
          ? href
          : `${href.pathname}${href.hash ? `#${href.hash}` : ''}`
      }
      {...props}
    >
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
});

afterEach(() => {
  window.history.replaceState(null, '', '/');
});

function renderAt(path: string) {
  window.history.replaceState(null, '', path);
  return render(
    <PresetProvider>
      <NotFoundRunner />
    </PresetProvider>
  );
}

describe('localeFromPath', () => {
  it('reads the locale prefix and falls back to English', () => {
    expect(localeFromPath('/id/buton')).toBe('id');
    expect(localeFromPath('/id')).toBe('id');
    expect(localeFromPath('/en/docs/nope')).toBe('en');
    expect(localeFromPath('/fr/xyz')).toBe('en');
    expect(localeFromPath('/identity')).toBe('en');
    expect(localeFromPath('')).toBe('en');
  });
});

describe('404 page', () => {
  it('speaks the locale of the path and names the path', () => {
    renderAt('/id/buton');
    expect(
      screen.getByRole('heading', {
        level: 1,
        name: 'Part 404 tidak ada di runner ini.',
      })
    ).toBeInTheDocument();
    expect(screen.getByText('/id/buton')).toBeInTheDocument();
    expect(document.documentElement.lang).toBe('id');
    expect(
      screen.getByRole('link', { name: /Kembali ke beranda/ })
    ).toHaveAttribute('href', '/id');
    expect(
      screen.getByRole('link', { name: 'Baca dokumentasi' })
    ).toHaveAttribute('href', '/id/docs/introduction');
  });

  it('hangs the nearest real parts, live, with their add commands', () => {
    renderAt('/en/buton');
    expect(screen.getByText('justui add button')).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'Copy justui add button' })
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Save changes' })).toBeVisible();
    expect(screen.getByRole('status')).toHaveTextContent(
      'No part named buton. Did you mean button?'
    );
  });

  it('re-ranks as the visitor types and only flags a miss as invalid', () => {
    renderAt('/en/buton');
    const field = screen.getByRole('textbox', { name: 'Look up a part' });
    expect(field).toHaveValue('buton');
    expect(field).toHaveAttribute('aria-invalid', 'false');

    fireEvent.change(field, { target: { value: 'card' } });
    expect(screen.getByRole('status')).toHaveTextContent(
      'card is 08 on this runner.'
    );
    expect(screen.getByText('justui add card')).toBeInTheDocument();

    fireEvent.change(field, { target: { value: 'zzzzzzzz' } });
    expect(screen.getByRole('status')).toHaveTextContent(
      'No part named zzzzzzzz.'
    );
    expect(field).toHaveAttribute('aria-invalid', 'true');
  });

  it('switches locale to the same path', () => {
    renderAt('/en/date_picker');
    const group = screen.getByRole('group', { name: 'Language' });
    expect(within(group).getByRole('link', { name: 'id' })).toHaveAttribute(
      'href',
      '/id/date_picker'
    );
    expect(screen.getByRole('textbox')).toHaveValue('date-picker');
  });

  it('decodes a percent-encoded path before the lookup', () => {
    renderAt('/en/date%20picker');
    expect(screen.getByRole('textbox')).toHaveValue('date-picker');
    expect(screen.getByRole('textbox')).toHaveAttribute(
      'aria-invalid',
      'false'
    );
    expect(screen.getByRole('status')).toHaveTextContent(
      'date-picker is 11 on this runner.'
    );
  });

  it('survives a malformed escape in the path', () => {
    renderAt('/en/%E0%A4%A');
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument();
  });

  it('titles the page in the locale of the path', () => {
    document.title = 'Part not found | JustUI';
    renderAt('/id/buton');
    expect(document.title).toBe('Part tidak ditemukan | JustUI');
  });

  it('has an English title for the prerendered page', () => {
    expect(metadata.title).toBe('Part not found');
  });
});

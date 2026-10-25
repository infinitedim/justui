import fs from 'node:fs';
import path from 'node:path';
import type { ReactNode } from 'react';
import { render, screen, within } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import ComponentsPage, {
  generateMetadata,
} from '@/app/[lang]/docs/components/page';
import { PresetProvider } from '@/components/providers';
import { PART_SLUGS } from '@/lib/parts';

vi.mock('next/link', () => ({
  default: ({
    children,
    href,
    prefetch: _prefetch,
    ...props
  }: {
    children: ReactNode;
    href: string;
    prefetch?: boolean;
  }) => (
    <a href={href} {...props}>
      {children}
    </a>
  ),
}));

vi.mock('fumadocs-ui/contexts/search', () => ({
  useSearchContext: () => ({ setOpenSearch: vi.fn() }),
}));

afterEach(() => {
  window.localStorage.clear();
});

async function renderPage(lang: string) {
  const page = await ComponentsPage({ params: Promise.resolve({ lang }) });
  return render(<PresetProvider>{page}</PresetProvider>);
}

function runners(): Array<HTMLElement> {
  return screen.getAllByRole('region');
}

describe('components page', () => {
  it('shows every part on six named runners', async () => {
    await renderPage('en');
    expect(
      screen.getByRole('heading', {
        level: 1,
        name: 'Every part on the runner',
      })
    ).toBeInTheDocument();
    expect(
      screen
        .getAllByRole('heading', { level: 2 })
        .map((heading) => heading.textContent)
    ).toEqual([
      'Actions',
      'Inputs',
      'Navigation',
      'Overlays',
      'Display',
      'Layout',
    ]);
    const parts = runners().flatMap((runner) =>
      within(runner).getAllByRole('listitem')
    );
    expect(parts).toHaveLength(33);
    expect(
      within(runners()[0] ?? document.body).getAllByRole('listitem')
    ).toHaveLength(3);
  });

  it('labels copy the add command and arrows open the docs', async () => {
    await renderPage('en');
    const copies = screen.getAllByRole('button', { name: /^Copy justui add / });
    expect(copies).toHaveLength(33);
    expect(copies[0]).toHaveAccessibleName('Copy justui add button');
    expect(copies[0]).toHaveTextContent('07button');
    const docs = screen.getAllByRole('link', { name: /^Open .* docs$/ });
    expect(docs).toHaveLength(33);
    expect(
      screen.getByRole('link', { name: 'Open button docs' })
    ).toHaveAttribute('href', '/en/docs/components/button');
  });

  it('renders the Indonesian page on /id', async () => {
    await renderPage('id');
    expect(
      screen.getByRole('heading', { level: 1, name: 'Semua part di runner' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('heading', { level: 2, name: 'Aksi' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('link', { name: 'Buka dokumentasi accordion' })
    ).toHaveAttribute('href', '/id/docs/components/accordion');
    expect(
      screen.getByRole('button', { name: 'Salin justui add tooltip' })
    ).toBeInTheDocument();
  });

  it('has per-locale metadata', async () => {
    const meta = await generateMetadata({
      params: Promise.resolve({ lang: 'id' }),
    });
    expect(meta.title).toBe('Komponen');
    expect(meta.description).toContain('33 part');
    expect(meta.alternates?.canonical).toBe('/id/docs/components');
    expect(meta.alternates?.languages).toEqual({
      en: '/en/docs/components',
      id: '/id/docs/components',
    });
  });

  it('links only to docs pages that exist in both locales', () => {
    const contentDir = path.resolve(__dirname, '../content/docs');
    for (const lang of ['en', 'id']) {
      const missing = PART_SLUGS.filter(
        (slug) =>
          !fs.existsSync(
            path.join(contentDir, lang, 'components', `${slug}.mdx`)
          )
      );
      expect(missing, lang).toEqual([]);
    }
  });
});

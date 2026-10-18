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

function partList(): HTMLElement {
  const list = screen.getByRole('main').querySelector('ul');
  if (!list) throw new Error('part list missing');
  return list;
}

describe('components page', () => {
  it('lists every part, linking to its docs', async () => {
    await renderPage('en');
    expect(
      screen.getByRole('heading', {
        level: 1,
        name: 'Every part on the runner',
      })
    ).toBeInTheDocument();
    const links = within(partList()).getAllByRole('link');
    expect(links).toHaveLength(33);
    expect(links[6]).toHaveAttribute('href', '/en/docs/components/button');
    expect(links[6]).toHaveAccessibleName('07 button');
  });

  it('copies the add command of each part', async () => {
    await renderPage('en');
    const buttons = within(partList()).getAllByRole('button', {
      name: /^Copy justui add /,
    });
    expect(buttons).toHaveLength(33);
    expect(buttons[6]).toHaveAccessibleName('Copy justui add button');
  });

  it('renders the Indonesian page on /id', async () => {
    await renderPage('id');
    expect(
      screen.getByRole('heading', { level: 1, name: 'Semua part di runner' })
    ).toBeInTheDocument();
    const links = within(partList()).getAllByRole('link');
    expect(links[0]).toHaveAttribute('href', '/id/docs/components/accordion');
    expect(
      within(partList()).getByRole('button', {
        name: 'Salin justui add tooltip',
      })
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

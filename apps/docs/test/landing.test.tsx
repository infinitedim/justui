import type { ReactNode } from 'react';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeAll, describe, expect, it, vi } from 'vitest';
import HomePage, { generateMetadata } from '@/app/[lang]/page';
import { PresetProvider } from '@/components/providers';

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

vi.mock('fumadocs-ui/contexts/search', () => ({
  useSearchContext: () => ({ setOpenSearch: vi.fn() }),
}));

beforeAll(() => {
  window.matchMedia = vi.fn().mockReturnValue({
    matches: true,
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
  });
});

/** The hero, where the runner box and its cut bar live. */
function heroSection(): HTMLElement {
  const hero = screen.getByRole('heading', { level: 1 }).closest('section');
  if (!hero) throw new Error('hero section missing');
  return hero;
}

async function renderLanding(lang: string) {
  const page = await HomePage({ params: Promise.resolve({ lang }) });
  return render(<PresetProvider>{page}</PresetProvider>);
}

describe('landing page', () => {
  it('opens with the headline, the description and a working install command', async () => {
    await renderLanding('en');
    expect(
      screen.getByRole('heading', {
        level: 1,
        name: 'One command. One file. Yours.',
      })
    ).toBeInTheDocument();
    const panel = screen.getByRole('tabpanel', { name: 'macOS / Linux' });
    expect(panel).toHaveTextContent(
      'curl -fsSL https://justui.vercel.app/install.sh | sh'
    );
    fireEvent.click(screen.getByRole('tab', { name: 'Windows' }));
    expect(screen.getByRole('tabpanel', { name: 'Windows' })).toHaveTextContent(
      'irm https://justui.vercel.app/install.ps1 | iex'
    );
    expect(
      screen.getByRole('button', { name: 'Copy install command' })
    ).toBeInTheDocument();
  });

  it('switches only the stage when the visitor picks another runner', async () => {
    const { container } = await renderLanding('en');
    const shelf = screen.getByRole('radiogroup', { name: 'Preset' });
    const neo = within(shelf).getByRole('radio', { name: /Neobrutalism/ });
    fireEvent.click(neo);
    expect(neo).toHaveAttribute('aria-checked', 'true');
    expect(container.querySelector('[data-pbox]')).toHaveClass(
      'theme-neobrutalism'
    );
    expect(container.querySelector('header')?.className).not.toMatch(
      /theme-neobrutalism|preset-default/
    );
  });

  it('cuts the part whose gate label is pressed', async () => {
    await renderLanding('en');
    const hero = heroSection();
    expect(within(hero).getByText('justui add button')).toBeInTheDocument();
    fireEvent.click(
      within(hero).getByRole('button', { name: /^27\s*switch$/ })
    );
    expect(within(hero).getByText('justui add switch')).toBeInTheDocument();
    expect(
      within(hero).getByText('lib/widgets/switch/just_switch.dart')
    ).toBeInTheDocument();
  });

  it('cuts part 07 into the files the registry lists', async () => {
    await renderLanding('en');
    const cut = screen.getByRole('region', {
      name: 'Cut one part. One file lands.',
    });
    for (const file of [
      'just_button.dart',
      'just_button_style.dart',
      'just_button_theme.dart',
      'just_button_variants.dart',
      'just_icon_button.dart',
    ]) {
      expect(within(cut).getAllByText(file).length).toBeGreaterThan(0);
    }
    expect(within(cut).getByText('+3 files')).toBeInTheDocument();
    expect(
      within(cut).getByText(
        '8 files written: 5 for button, 3 shared dependencies. Each checked against the registry checksum'
      )
    ).toBeInTheDocument();
  });

  it('switches between before and after under reduced motion', async () => {
    const { container } = await renderLanding('en');
    const slot = container.querySelector<HTMLElement>('[data-cut="slot"]');
    const verify = container.querySelector<HTMLElement>('[data-cut="verify"]');
    expect(slot?.style.opacity).toBe('0');
    fireEvent.click(screen.getByRole('button', { name: 'Before' }));
    expect(slot?.style.opacity).toBe('1');
    expect(verify?.style.opacity).toBe('0');
    fireEvent.click(screen.getByRole('button', { name: 'After' }));
    expect(slot?.style.opacity).toBe('0');
    expect(verify?.style.opacity).toBe('1');
  });

  it('pins the cut stage when motion is allowed', async () => {
    const reduced = window.matchMedia;
    window.matchMedia = vi.fn().mockReturnValue({
      matches: false,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
    });
    try {
      await renderLanding('en');
      const cut = screen.getByRole('region', {
        name: 'Cut one part. One file lands.',
      });
      expect(cut).toHaveClass('h-[280vh]');
      expect(cut.querySelector('[data-raster-sticky]')).toBeInTheDocument();
      expect(
        screen.queryByRole('button', { name: 'Before' })
      ).not.toBeInTheDocument();
    } finally {
      window.matchMedia = reduced;
    }
  });

  it('renders the Indonesian copy on /id', async () => {
    await renderLanding('id');
    expect(
      screen.getByRole('heading', {
        level: 1,
        name: 'Satu perintah. Satu file. Milikmu.',
      })
    ).toBeInTheDocument();
    expect(screen.getByText('Runner di dalam kotak ini')).toBeInTheDocument();
  });

  it('gives each locale its own metadata', async () => {
    const en = await generateMetadata({
      params: Promise.resolve({ lang: 'en' }),
    });
    const id = await generateMetadata({
      params: Promise.resolve({ lang: 'id' }),
    });
    expect(en.title).toBe('One command. One file. Yours.');
    expect(id.title).toBe('Satu perintah. Satu file. Milikmu.');
    expect(en.alternates?.languages).toEqual({ en: '/en', id: '/id' });
  });
});

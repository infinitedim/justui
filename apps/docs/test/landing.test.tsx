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
    expect(screen.getByText('justui add button')).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: /^27\s*switch$/ }));
    expect(screen.getByText('justui add switch')).toBeInTheDocument();
    expect(
      screen.getByText('lib/widgets/switch/just_switch.dart')
    ).toBeInTheDocument();
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

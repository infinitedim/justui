import { render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import HomePage from '@/app/[lang]/page';

vi.mock('@/lib/github', () => ({
  fetchStarCount: vi.fn().mockResolvedValue(1200),
  githubUrl: 'https://github.com/infinitedim/justui',
}));

vi.mock('next/navigation', () => ({
  usePathname: () => '/en',
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    prefetch: vi.fn(),
  }),
}));

vi.mock('next/link', () => ({
  default: ({
    children,
    href,
    className,
    ...props
  }: {
    children: React.ReactNode;
    href: string;
    className?: string;
  }) => (
    <a href={href} className={className} data-testid="next-link" {...props}>
      {children}
    </a>
  ),
}));

// CustomSearchDialog needs a fumadocs FrameworkProvider this unit test
// doesn't set up; its own behavior is covered by test/search.test.tsx.
vi.mock('@/components/search', () => ({
  default: () => null,
}));

describe('HomePage Component', () => {
  it('renders the hero heading and description', async () => {
    const page = await HomePage({ params: Promise.resolve({ lang: 'en' }) });
    render(page);

    expect(
      screen.getByRole('heading', {
        level: 1,
        name: /one command\. one file\. yours\./i,
      })
    ).toBeInTheDocument();

    expect(
      screen.getByText(/not a dependency\. justui copies flutter components/i)
    ).toBeInTheDocument();
  });

  it('renders the primary homepage actions', async () => {
    const page = await HomePage({ params: Promise.resolve({ lang: 'en' }) });
    render(page);

    expect(screen.getByRole('link', { name: /get started/i })).toHaveAttribute(
      'href',
      '/en/docs/introduction'
    );
    expect(
      screen.getByRole('link', { name: /browse components/i })
    ).toHaveAttribute('href', '/en/components');
  });

  it('renders the install tabs and interactive hero section', async () => {
    const page = await HomePage({ params: Promise.resolve({ lang: 'en' }) });
    render(page);

    expect(
      screen.getByText('curl -fsSL https://justui.vercel.app/install.sh | sh')
    ).toBeInTheDocument();
    expect(
      screen.getByRole('region', { name: /interactive terminal/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('region', { name: /living widget stage/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('radiogroup', { name: /preset spotlight/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('heading', { level: 2, name: /^components$/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('heading', {
        level: 2,
        name: /what you actually get/i,
      })
    ).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /JustButton/i })).toHaveAttribute(
      'href',
      '/en/docs/components/button'
    );
    expect(
      screen.getByRole('link', { name: /JustSwitch/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('contentinfo', { name: /site footer/i })
    ).toBeInTheDocument();
  });
});

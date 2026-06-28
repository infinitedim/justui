import { render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import HomePage from '@/app/[lang]/page';

vi.mock('@/lib/github', () => ({
  fetchStarCount: vi.fn().mockResolvedValue(1200),
  githubUrl: 'https://github.com/infinitedim/justui',
}));

vi.mock('next/navigation', () => ({
  usePathname: () => '/en',
}));

// Mock next/link to render simple anchor tags
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

describe('HomePage Component', () => {
  it('renders the hero heading and description', async () => {
    const page = await HomePage();
    render(page);

    expect(
      screen.getByRole('heading', { level: 1, name: /copy\. paste\. ship\./i })
    ).toBeInTheDocument();

    expect(
      screen.getByText(/A zero-dependency, copy-paste component library/i)
    ).toBeInTheDocument();
  });

  it('renders the primary homepage actions', async () => {
    const page = await HomePage();
    render(page);

    expect(screen.getByRole('link', { name: /get started/i })).toHaveAttribute(
      'href',
      '/en/docs/introduction'
    );
    expect(
      screen.getByRole('link', { name: /browse components/i })
    ).toHaveAttribute('href', '/en/docs/components');
  });

  it('renders the install command and component grid', async () => {
    const page = await HomePage();
    render(page);

    expect(
      screen.getByText('flutter pub add just_ui_core')
    ).toBeInTheDocument();
    expect(
      screen.getByRole('heading', { name: /components/i })
    ).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /JustButton/i })).toHaveAttribute(
      'href',
      '/en/docs/components/button'
    );
    expect(
      screen.getByRole('link', { name: /JustSwitch/i })
    ).toBeInTheDocument();
  });
});

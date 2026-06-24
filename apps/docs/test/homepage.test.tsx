import { render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import HomePage from '@/app/[lang]/page';

// Mock next/link to render simple anchor tags
vi.mock('next/link', () => ({
  default: ({
    children,
    href,
    className,
  }: {
    children: React.ReactNode;
    href: string;
    className?: string;
  }) => (
    <a href={href} className={className} data-testid="next-link">
      {children}
    </a>
  ),
}));

describe('HomePage Component', () => {
  it('renders the main heading and description', async () => {
    const page = await HomePage({ params: Promise.resolve({ lang: 'id' }) });
    render(page);

    // Check header text
    const heading = screen.getByRole('heading', { level: 1 });
    expect(heading).toHaveTextContent('JustUI');

    // Check description text
    const description = screen.getByText(
      /Flutter UI component library built on the copy-paste philosophy/i
    );
    expect(description).toBeInTheDocument();
  });

  it('renders the primary action buttons', async () => {
    const page = await HomePage({ params: Promise.resolve({ lang: 'id' }) });
    render(page);

    // Check "Baca Dokumentasi" link
    const docsLink = screen.getByRole('link', { name: /baca dokumentasi/i });
    expect(docsLink).toBeInTheDocument();
    expect(docsLink).toHaveAttribute('href', '/id/docs/introduction');

    // Check "GitHub" link
    const githubLink = screen.getByRole('link', { name: /github/i });
    expect(githubLink).toBeInTheDocument();
    expect(githubLink).toHaveAttribute(
      'href',
      'https://github.com/infinitedim/justui'
    );
  });

  it('renders features grid with all key benefits', async () => {
    const page = await HomePage({ params: Promise.resolve({ lang: 'id' }) });
    render(page);

    // Check feature cards headings
    expect(
      screen.getByRole('heading', { name: /zero-dependency/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('heading', { name: /copy-paste model/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('heading', { name: /neobrutalism style/i })
    ).toBeInTheDocument();
  });
});

import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Footer } from '@/components/organisms/footer';

describe('Footer Organism', () => {
  it('renders brand identity, links, and release version in English', () => {
    render(<Footer lang="en" />);

    expect(
      screen.getByRole('contentinfo', { name: /site footer/i })
    ).toBeInTheDocument();
    expect(screen.getByText('v0.14.0')).toBeInTheDocument();
    expect(screen.getByText('Flutter 3.29+')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /introduction/i })).toHaveAttribute(
      'href',
      '/en/docs/introduction'
    );
    expect(screen.getByRole('link', { name: /cli guide/i })).toHaveAttribute(
      'href',
      '/en/docs/cli'
    );
    expect(
      screen.getByRole('link', { name: /github repository/i })
    ).toHaveAttribute('href', 'https://github.com/infinitedim/justui');
  });

  it('renders localized links and descriptions in Indonesian', () => {
    render(<Footer lang="id" />);

    expect(screen.getByText('Dokumentasi')).toBeInTheDocument();
    expect(screen.getByText('Ekosistem')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /pengenalan/i })).toHaveAttribute(
      'href',
      '/id/docs/introduction'
    );
    expect(
      screen.getByRole('link', { name: /laporkan masalah/i })
    ).toHaveAttribute('href', 'https://github.com/infinitedim/justui/issues');
  });
});

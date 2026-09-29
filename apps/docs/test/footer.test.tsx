import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Footer } from '@/components/organisms/footer';

describe('Footer Organism', () => {
  it('renders brand identity, links, and release version in English', () => {
    render(<Footer lang="en" />);

    expect(
      screen.getByRole('contentinfo', { name: /site footer/i })
    ).toBeInTheDocument();
    expect(screen.getByText('Docs')).toBeInTheDocument();
    expect(screen.getByText('Project')).toBeInTheDocument();
    expect(
      screen.getByText(
        'Flutter components you copy into your project. MIT licensed.'
      )
    ).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /introduction/i })).toHaveAttribute(
      'href',
      '/en/docs/introduction'
    );
    expect(screen.getByRole('link', { name: /cli setup/i })).toHaveAttribute(
      'href',
      '/en/docs/cli-setup'
    );
    expect(
      screen.getByRole('link', { name: /github/i })
    ).toHaveAttribute('href', 'https://github.com/infinitedim/justui');
  });

  it('renders localized links and descriptions in Indonesian', () => {
    render(<Footer lang="id" />);

    expect(screen.getByText('Dokumentasi')).toBeInTheDocument();
    expect(screen.getByText('Proyek')).toBeInTheDocument();
    expect(
      screen.getByText(
        'Komponen Flutter yang kamu salin ke proyekmu. Lisensi MIT.'
      )
    ).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /pengenalan/i })).toHaveAttribute(
      'href',
      '/id/docs/introduction'
    );
    expect(
      screen.getByRole('link', { name: /issue/i })
    ).toHaveAttribute('href', 'https://github.com/infinitedim/justui/issues');
  });
});

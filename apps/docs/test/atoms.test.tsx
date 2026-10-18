import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Kbd } from '@/components/atoms/kbd';
import { Code } from '@/components/atoms/code';
import { LogoMark } from '@/components/atoms/logo-mark';
import { GitHubMark } from '@/components/atoms/github-mark';

describe('Atoms Components', () => {
  describe('Kbd', () => {
    it('renders keyboard shortcut', () => {
      render(<Kbd>Ctrl+K</Kbd>);
      expect(screen.getByText('Ctrl+K')).toBeInTheDocument();
    });
  });

  describe('Code', () => {
    it('renders inline code', () => {
      render(<Code>const x = 1;</Code>);
      expect(screen.getByText('const x = 1;')).toBeInTheDocument();
    });

    it('renders block code inside pre', () => {
      const { container } = render(<Code block>const a = 2;</Code>);
      expect(container.querySelector('pre')).toBeInTheDocument();
    });
  });

  describe('LogoMark', () => {
    it('renders svg with custom size', () => {
      const { container } = render(<LogoMark size={32} />);
      const svg = container.querySelector('svg');
      expect(svg).toBeInTheDocument();
      expect(svg).toHaveAttribute('width', '32');
      expect(svg).toHaveAttribute('height', '32');
    });
  });

  describe('GitHubMark', () => {
    it('renders svg with custom size and default aria-hidden', () => {
      const { container } = render(
        <GitHubMark size={14} className="custom-class" />
      );
      const svg = container.querySelector('svg');
      expect(svg).toBeInTheDocument();
      expect(svg).toHaveAttribute('width', '14');
      expect(svg).toHaveAttribute('height', '14');
      expect(svg).toHaveAttribute('aria-hidden', 'true');
      expect(svg).toHaveAttribute('fill', 'currentColor');
      expect(svg).toHaveClass('custom-class');
    });

    it('renders with default size when not specified', () => {
      const { container } = render(<GitHubMark />);
      const svg = container.querySelector('svg');
      expect(svg).toBeInTheDocument();
      expect(svg).toHaveAttribute('width', '16');
      expect(svg).toHaveAttribute('height', '16');
    });
  });
});

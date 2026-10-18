import { describe, expect, it } from 'vitest';
import { render } from '@testing-library/react';
import { GitHubMark } from '@/components/atoms/github-mark';

describe('Atoms Components', () => {
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

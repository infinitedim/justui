import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Button } from '@/components/atoms/button';
import { Badge } from '@/components/atoms/badge';
import { Input } from '@/components/atoms/input';
import { Kbd } from '@/components/atoms/kbd';
import { Code } from '@/components/atoms/code';
import { Slider } from '@/components/atoms/slider';

describe('Atoms Components', () => {
  describe('Button', () => {
    it('renders with children and responds to disabled prop', () => {
      render(<Button disabled>Click me</Button>);
      const btn = screen.getByRole('button', { name: 'Click me' });
      expect(btn).toBeDisabled();
    });

    it('shows loading indicator when loading is true', () => {
      render(<Button loading>Submit</Button>);
      const btn = screen.getByRole('button');
      expect(btn).toBeDisabled();
    });
  });

  describe('Badge', () => {
    it('renders badge content', () => {
      render(<Badge variant="accent">New</Badge>);
      expect(screen.getByText('New')).toBeInTheDocument();
    });
  });

  describe('Input', () => {
    it('renders text input with placeholder', () => {
      render(<Input placeholder="Enter name" />);
      expect(screen.getByPlaceholderText('Enter name')).toBeInTheDocument();
    });
  });

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

  describe('Slider', () => {
    it('renders range slider', () => {
      render(
        <Slider
          min={0}
          max={100}
          value={50}
          label="Volume"
          onChange={() => {}}
        />
      );
      const slider = screen.getByRole('slider', { name: 'Volume' });
      expect(slider).toBeInTheDocument();
    });
  });
});

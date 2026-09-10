import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Typography } from '@/components/atoms/typography';
import { Button } from '@/components/atoms/button';
import { Badge } from '@/components/atoms/badge';
import { Input } from '@/components/atoms/input';
import { Kbd } from '@/components/atoms/kbd';
import { Icon } from '@/components/atoms/icon';
import { Code } from '@/components/atoms/code';
import { Separator } from '@/components/atoms/separator';
import { Spinner } from '@/components/atoms/spinner';
import { SkeletonBox } from '@/components/atoms/skeleton-box';
import { ProgressBar } from '@/components/atoms/progress-bar';
import { Slider } from '@/components/atoms/slider';
import { ToggleChip } from '@/components/atoms/toggle-chip';
import { TooltipBubble } from '@/components/atoms/tooltip-bubble';
import { AvatarCircle } from '@/components/atoms/avatar-circle';
import { DotGrid } from '@/components/atoms/dot-grid';
import { Check } from 'lucide-react';

describe('Atoms Components', () => {
  describe('Typography', () => {
    it('renders default body paragraph', () => {
      render(<Typography>Body text</Typography>);
      const el = screen.getByText('Body text');
      expect(el.tagName).toBe('P');
    });

    it('renders heading with h1 variant', () => {
      render(<Typography variant="h1">Heading 1</Typography>);
      const el = screen.getByRole('heading', { level: 1 });
      expect(el).toHaveTextContent('Heading 1');
    });

    it('supports custom tag via as prop', () => {
      render(
        <Typography as="span" variant="h2">
          Span Heading
        </Typography>
      );
      const el = screen.getByText('Span Heading');
      expect(el.tagName).toBe('SPAN');
    });
  });

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

  describe('Icon', () => {
    it('renders icon with label', () => {
      render(<Icon icon={Check} label="Success checkmark" />);
      expect(
        screen.getByRole('img', { name: 'Success checkmark' })
      ).toBeInTheDocument();
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

  describe('Separator', () => {
    it('renders decorative separator by default', () => {
      const { container } = render(<Separator />);
      expect(container.firstChild).toHaveAttribute('role', 'none');
    });

    it('renders semantic separator when decorative is false', () => {
      render(<Separator decorative={false} orientation="vertical" />);
      const sep = screen.getByRole('separator');
      expect(sep).toHaveAttribute('aria-orientation', 'vertical');
    });
  });

  describe('Spinner', () => {
    it('renders status role with label', () => {
      render(<Spinner label="Loading items" />);
      expect(
        screen.getByRole('status', { name: 'Loading items' })
      ).toBeInTheDocument();
    });
  });

  describe('SkeletonBox', () => {
    it('renders placeholder with aria-hidden', () => {
      const { container } = render(<SkeletonBox width="100px" height="20px" />);
      expect(container.firstChild).toHaveAttribute('aria-hidden', 'true');
    });
  });

  describe('ProgressBar', () => {
    it('renders progressbar role with percentage', () => {
      render(<ProgressBar value={40} max={100} label="Upload progress" />);
      const bar = screen.getByRole('progressbar', { name: 'Upload progress' });
      expect(bar).toHaveAttribute('aria-valuenow', '40');
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

  describe('ToggleChip', () => {
    it('renders pressed state correctly', () => {
      render(<ToggleChip active>Filter</ToggleChip>);
      expect(screen.getByRole('button', { pressed: true })).toBeInTheDocument();
    });
  });

  describe('TooltipBubble', () => {
    it('renders tooltip role when visible', () => {
      render(<TooltipBubble visible>Help text</TooltipBubble>);
      expect(screen.getByRole('tooltip')).toHaveTextContent('Help text');
    });

    it('does not render when visible is false', () => {
      render(<TooltipBubble visible={false}>Hidden</TooltipBubble>);
      expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();
    });
  });

  describe('AvatarCircle', () => {
    it('renders fallback text when src is missing', () => {
      render(<AvatarCircle fallback="JD" alt="John Doe" />);
      expect(screen.getByText('JD')).toBeInTheDocument();
    });

    it('renders img when src is provided', () => {
      render(<AvatarCircle src="/avatar.png" alt="Profile" />);
      expect(screen.getByRole('img', { name: 'Profile' })).toBeInTheDocument();
    });
  });

  describe('DotGrid', () => {
    it('renders decorative dot grid container', () => {
      const { container } = render(<DotGrid cols={4} rows={4} />);
      expect(container.firstChild).toHaveAttribute('aria-hidden', 'true');
    });
  });
});

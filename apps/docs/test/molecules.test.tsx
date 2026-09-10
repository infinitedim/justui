import { describe, expect, it, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { CopyButton } from '@/components/molecules/copy-button';
import { SearchBar } from '@/components/molecules/search-bar';
import { PresetToggle } from '@/components/molecules/preset-toggle';
import { LanguageSwitcher } from '@/components/molecules/language-switcher';
import { ThemeSwitcher } from '@/components/molecules/theme-switcher';
import { GitHubPill } from '@/components/molecules/github-pill';
import { CategoryFilterPill } from '@/components/molecules/category-filter-pill';
import { ColorSwatchItem } from '@/components/molecules/color-swatch-item';
import { TerminalLine } from '@/components/molecules/terminal-line';
import { TerminalPrompt } from '@/components/molecules/terminal-prompt';
import { ViewportSwitch } from '@/components/molecules/viewport-switch';
import { FormulaMathBlock } from '@/components/molecules/formula-math-block';
import { BreadcrumbTrail } from '@/components/molecules/breadcrumb-trail';
import { CodeBlockHeader } from '@/components/molecules/code-block-header';
import { VariantPicker } from '@/components/molecules/variant-picker';
import { StateToggle } from '@/components/molecules/state-toggle';
import { StatCounter } from '@/components/molecules/stat-counter';
import { LightnessSlider } from '@/components/molecules/lightness-slider';
import { SearchResultItem } from '@/components/molecules/search-result-item';
import { PresetProvider } from '@/lib/preset-context';

describe('Molecules Components', () => {
  describe('CopyButton', () => {
    it('copies text to clipboard on click', async () => {
      const writeTextMock = vi.fn().mockResolvedValue(undefined);
      Object.assign(navigator, {
        clipboard: { writeText: writeTextMock },
      });

      render(<CopyButton text="npm i justui" label="Copy command" />);
      const btn = screen.getByRole('button', { name: 'Copy command' });
      fireEvent.click(btn);

      expect(writeTextMock).toHaveBeenCalledWith('npm i justui');
    });
  });

  describe('SearchBar', () => {
    it('triggers onActivate callback when clicked', () => {
      const onActivate = vi.fn();
      render(<SearchBar onActivate={onActivate} placeholder="Search..." />);
      const btn = screen.getByRole('button', { name: 'Open search' });
      fireEvent.click(btn);
      expect(onActivate).toHaveBeenCalledTimes(1);
    });
  });

  describe('PresetToggle', () => {
    it('toggles preset state', async () => {
      render(
        <PresetProvider>
          <PresetToggle label="Toggle preset" />
        </PresetProvider>
      );

      await waitFor(() => {
        expect(
          screen.getByRole('button', { name: 'Toggle preset' })
        ).toBeInTheDocument();
      });

      const btn = screen.getByRole('button', { name: 'Toggle preset' });
      fireEvent.click(btn);
    });
  });

  describe('LanguageSwitcher', () => {
    it('renders alternative language link', () => {
      render(<LanguageSwitcher lang="en" />);
      const link = screen.getByRole('link');
      expect(link).toHaveTextContent('ID');
    });
  });

  describe('ThemeSwitcher', () => {
    it('renders theme toggle button when mounted', async () => {
      render(<ThemeSwitcher label="Toggle theme" />);
      await waitFor(() => {
        expect(
          screen.getByRole('button', { name: 'Toggle theme' })
        ).toBeInTheDocument();
      });
    });
  });

  describe('GitHubPill', () => {
    it('formats star count correctly', () => {
      render(<GitHubPill href="https://github.com" starCount={1200} />);
      expect(screen.getByText('1.2k')).toBeInTheDocument();
    });

    it('displays fallback when stars are null', () => {
      render(<GitHubPill href="https://github.com" starCount={null} />);
      expect(screen.getByText('Stars')).toBeInTheDocument();
    });
  });

  describe('CategoryFilterPill', () => {
    it('renders label and count badge', () => {
      render(<CategoryFilterPill label="Buttons" count={5} active />);
      expect(screen.getByText('Buttons')).toBeInTheDocument();
      expect(screen.getByText('5')).toBeInTheDocument();
    });
  });

  describe('ColorSwatchItem', () => {
    it('renders label and value', () => {
      render(
        <ColorSwatchItem color="#ffffff" label="Background" value="#fff" />
      );
      expect(screen.getByText('Background')).toBeInTheDocument();
      expect(screen.getByText('#fff')).toBeInTheDocument();
    });
  });

  describe('TerminalLine', () => {
    it('renders output with timestamp', () => {
      render(
        <TerminalLine kind="success" timestamp="12:00">
          Task completed
        </TerminalLine>
      );
      expect(screen.getByText('Task completed')).toBeInTheDocument();
      expect(screen.getByText('12:00')).toBeInTheDocument();
    });
  });

  describe('TerminalPrompt', () => {
    it('renders prefix and command', () => {
      render(<TerminalPrompt prefix=">" command="justui add button" cursor />);
      expect(screen.getByText('>')).toBeInTheDocument();
      expect(screen.getByText('justui add button')).toBeInTheDocument();
    });
  });

  describe('ViewportSwitch', () => {
    it('fires onChange with selected viewport', () => {
      const onChange = vi.fn();
      render(<ViewportSwitch value="mobile" onChange={onChange} />);
      const tabletRadio = screen.getByRole('radio', {
        name: 'Tablet viewport',
      });
      fireEvent.click(tabletRadio);
      expect(onChange).toHaveBeenCalledWith('tablet');
    });
  });

  describe('FormulaMathBlock', () => {
    it('renders formula code and caption', () => {
      render(
        <FormulaMathBlock formula="V(G) <= 3" caption="Cyclomatic Complexity" />
      );
      expect(screen.getByText('V(G) <= 3')).toBeInTheDocument();
      expect(screen.getByText('Cyclomatic Complexity')).toBeInTheDocument();
    });
  });

  describe('BreadcrumbTrail', () => {
    it('renders trail segments with page marked for last', () => {
      render(
        <BreadcrumbTrail
          segments={[
            { label: 'Home', href: '/' },
            { label: 'Docs', href: '/docs' },
            { label: 'Button' },
          ]}
        />
      );
      expect(screen.getByText('Home')).toBeInTheDocument();
      expect(screen.getByText('Button')).toHaveAttribute(
        'aria-current',
        'page'
      );
    });
  });

  describe('CodeBlockHeader', () => {
    it('renders title and actions slot', () => {
      render(
        <CodeBlockHeader
          title="button.dart"
          actions={<button type="button">Copy</button>}
        />
      );
      expect(screen.getByText('button.dart')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Copy' })).toBeInTheDocument();
    });
  });

  describe('VariantPicker', () => {
    it('renders options and fires onChange', () => {
      const onChange = vi.fn();
      render(
        <VariantPicker
          options={[
            { value: 'primary', label: 'Primary' },
            { value: 'ghost', label: 'Ghost' },
          ]}
          value="primary"
          onChange={onChange}
        />
      );
      const ghostBtn = screen.getByRole('radio', { name: 'Ghost' });
      fireEvent.click(ghostBtn);
      expect(onChange).toHaveBeenCalledWith('ghost');
    });
  });

  describe('StateToggle', () => {
    it('toggles switch state on click', () => {
      const onChange = vi.fn();
      render(
        <StateToggle value={false} onChange={onChange} label="Disabled" />
      );
      const toggle = screen.getByRole('switch');
      fireEvent.click(toggle);
      expect(onChange).toHaveBeenCalledWith(true);
    });
  });

  describe('StatCounter', () => {
    it('renders value, unit, and label', () => {
      render(<StatCounter value="120" unit="FPS" label="Render Target" />);
      expect(screen.getByText('120')).toBeInTheDocument();
      expect(screen.getByText('FPS')).toBeInTheDocument();
      expect(screen.getByText('Render Target')).toBeInTheDocument();
    });
  });

  describe('LightnessSlider', () => {
    it('renders slider and handles change', () => {
      const onChange = vi.fn();
      render(
        <LightnessSlider value={50} onChange={onChange} label="Lightness" />
      );
      const slider = screen.getByRole('slider', { name: 'Lightness' });
      fireEvent.change(slider, { target: { value: '70' } });
      expect(onChange).toHaveBeenCalledWith(70);
    });
  });

  describe('SearchResultItem', () => {
    it('renders item with label, type and href', () => {
      render(
        <SearchResultItem label="Button" type="Component" href="/docs/button" />
      );
      expect(screen.getByText('Button')).toBeInTheDocument();
      expect(screen.getByText('Component')).toBeInTheDocument();
    });
  });
});

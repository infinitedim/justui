import { describe, expect, it, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { CopyButton } from '@/components/molecules/copy-button';
import { SearchBar } from '@/components/molecules/search-bar';
import { PresetToggle } from '@/components/molecules/preset-toggle';
import { LanguageSwitcher } from '@/components/molecules/language-switcher';
import { ThemeSwitcher } from '@/components/molecules/theme-switcher';
import { GitHubPill } from '@/components/molecules/github-pill';
import { TerminalLine } from '@/components/molecules/terminal-line';
import { TerminalPrompt } from '@/components/molecules/terminal-prompt';
import { ViewportSwitch } from '@/components/molecules/viewport-switch';
import { PresetProvider } from '@/components/providers';

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
          screen.getByRole('radiogroup', { name: 'Toggle preset' })
        ).toBeInTheDocument();
      });

      const neoBtn = screen.getByRole('radio', { name: 'neobrutalism' });
      fireEvent.click(neoBtn);
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
          screen.getByRole('switch', { name: 'Toggle theme' })
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

    it('colors only the leading CLI glyph and keeps the words in foreground', () => {
      render(
        <TerminalLine kind="success">
          {'\u2713 Component "card" added successfully.'}
        </TerminalLine>
      );
      const glyph = screen.getByText('\u2713');
      expect(glyph).toHaveClass('text-success');
      expect(glyph.parentElement?.parentElement).toHaveClass('text-foreground');
    });
  });

  describe('TerminalPrompt', () => {
    it('renders prefix and command', () => {
      render(<TerminalPrompt prefix=">" command="justui add button" />);
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
});

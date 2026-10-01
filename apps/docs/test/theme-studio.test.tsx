import { describe, expect, it, vi, beforeEach } from 'vitest';
import { act, render, screen, fireEvent } from '@testing-library/react';
import { StudioClient } from '@/app/[lang]/studio/studio-client';
import StudioPage, {
  generateMetadata,
  generateStaticParams,
} from '@/app/[lang]/studio/page';
import { ThemeConfigurator } from '@/components/organisms/theme-configurator';
import { StudioPreview } from '@/components/organisms/studio-preview';
import { PresetProvider } from '@/components/providers';
import { CodeExportDrawer } from '@/components/organisms/code-export-drawer';
import { ThemeStudioProvider } from '@/lib/theme-studio-context';
import { hexToHsl } from '@/lib/theme/color-resolver';

vi.mock('next/navigation', () => ({
  usePathname: () => '/en',
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    prefetch: vi.fn(),
  }),
  notFound: vi.fn(),
}));

vi.mock('@/lib/github', () => ({
  fetchStarCount: vi.fn().mockResolvedValue(1200),
  githubUrl: 'https://github.com/infinitedim/justui',
}));

// CustomSearchDialog needs a fumadocs FrameworkProvider this unit test
// doesn't set up; its own behavior is covered by test/search.test.tsx.
vi.mock('@/components/search', () => ({
  default: () => null,
}));

describe('Theme Studio Component & Integration Tests', () => {
  beforeEach(() => {
    window.history.replaceState(null, '', '/en/studio');
    Object.assign(navigator, {
      clipboard: {
        writeText: vi.fn().mockImplementation(() => Promise.resolve()),
      },
    });
  });

  describe('ThemeStudio Layout & Organisms', () => {
    it('renders the complete studio page with all three organisms', () => {
      render(<StudioClient lang="en" />);

      expect(screen.getByTestId('theme-configurator')).toBeInTheDocument();
      expect(screen.getByTestId('studio-preview')).toBeInTheDocument();
      expect(screen.queryByText('Live Token Playground')).toBeNull();
      expect(
        screen.getByRole('heading', { level: 1, name: 'Theme Studio' })
      ).toHaveClass('font-medium');
      expect(screen.getByTestId('code-export-drawer')).toBeInTheDocument();
      expect(
        screen.getByRole('heading', { level: 1, name: 'Theme Studio' })
      ).toBeInTheDocument();
    });

    it('renders localized content when lang is id (Indonesian)', () => {
      render(<StudioClient lang="id" />);

      expect(
        screen.getByText(/Pilih satu warna\. Studio menurunkan palet/)
      ).toBeInTheDocument();
      expect(screen.getByText('Warna dasar')).toBeInTheDocument();
      expect(screen.getByText('Ruang warna')).toBeInTheDocument();
    });
  });

  describe('ThemeConfigurator Organism', () => {
    it('renders the seed input without a generic Tailwind swatch palette', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      expect(screen.getByLabelText('Seed color as hex')).toHaveValue('#a3e635');
      expect(screen.queryByText('Violet')).not.toBeInTheDocument();
      expect(screen.queryByText('Cyan')).not.toBeInTheDocument();
    });

    it('keeps a history of recently used seeds that can be re-applied', async () => {
      vi.useFakeTimers();
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const input = screen.getByLabelText('Seed color as hex');
      await act(async () => {
        await vi.advanceTimersByTimeAsync(700);
      });
      fireEvent.change(input, { target: { value: '#3b82f6' } });
      await act(async () => {
        await vi.advanceTimersByTimeAsync(700);
      });

      fireEvent.click(screen.getByRole('button', { name: '#a3e635' }));
      expect(input).toHaveValue('#a3e635');
      vi.useRealTimers();
    });

    it('explains what the color space setting changes', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      expect(
        screen.getByText(/Sets color_space for JustThemeData.fromSeed/)
      ).toBeInTheDocument();
    });

    it('normalizes hex input on blur', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const input = screen.getByLabelText('Seed color as hex');
      fireEvent.change(input, { target: { value: '#3b82f6' } });
      fireEvent.blur(input);

      expect(input).toHaveValue('#3b82f6');
    });

    it('preserves hue when lightness slider is dragged to extremes and back', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const slider = screen.getByRole('slider', { name: 'Lightness' });

      // Drag to 0%
      fireEvent.change(slider, { target: { value: '0' } });
      expect(screen.getByLabelText('Seed color as hex')).toHaveValue('#000000');

      // Drag back to 55%
      fireEvent.change(slider, { target: { value: '55' } });
      // Should recover lime tone, not stay black/gray
      const val = (
        screen.getByLabelText('Seed color as hex') as HTMLInputElement
      ).value;
      expect(val).not.toBe('#000000');
      expect(val).not.toBe('#8c8c8c');
      const [recoveredH, recoveredS] = hexToHsl(val);
      expect(recoveredH).toBe(83);
      expect(recoveredS).toBeGreaterThan(70);
    });

    it('allows toggling dark mode', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const toggle = screen.getByRole('switch');
      expect(toggle).toHaveAttribute('aria-checked', 'false');

      fireEvent.click(toggle);
      expect(toggle).toHaveAttribute('aria-checked', 'true');
    });

    it('shows the site-wide preset instead of keeping its own picker', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      expect(
        screen.queryByRole('radio', { name: 'neobrutalism' })
      ).not.toBeInTheDocument();
      expect(screen.getByText('default')).toBeInTheDocument();
    });

    it('renders resolved palette tokens with WCAG contrast badges', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      expect(screen.getByText('Resolved palette')).toBeInTheDocument();
      expect(screen.getByText('colors.textPrimary')).toBeInTheDocument();
      expect(screen.getByText('colors.borderDefault')).toBeInTheDocument();
      expect(screen.getAllByText('on background').length).toBeGreaterThan(0);
      // Background has nothing to be measured against, so no "1.0" badge.
      expect(screen.queryByText('1.0:1')).not.toBeInTheDocument();
    });

    it('only claims success after the clipboard write actually resolves', async () => {
      let resolveWrite: () => void = () => {};
      Object.assign(navigator, {
        clipboard: {
          writeText: vi.fn(
            () => new Promise<void>((resolve) => (resolveWrite = resolve))
          ),
        },
      });

      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const copyButton = screen.getAllByRole('button', {
        name: /^Copy colors\./,
      })[0];
      fireEvent.click(copyButton);

      // Clipboard write hasn't resolved yet: must not claim success early.
      expect(screen.queryByText('Copied')).not.toBeInTheDocument();

      resolveWrite();
      await screen.findByText('Copied');
    });

    it('shows a failure state instead of a false "Copied" when the clipboard write rejects', async () => {
      Object.assign(navigator, {
        clipboard: {
          writeText: vi.fn().mockRejectedValue(new Error('denied')),
        },
      });

      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const copyButton = screen.getAllByRole('button', {
        name: /^Copy colors\./,
      })[0];
      fireEvent.click(copyButton);

      await screen.findByText('Copy failed');
      expect(screen.queryByText('Copied')).not.toBeInTheDocument();
    });
  });

  describe('StudioPreview Organism', () => {
    it('shows real components without device chrome, metrics or versions', () => {
      render(
        <ThemeStudioProvider>
          <StudioPreview lang="en" />
        </ThemeStudioProvider>
      );

      expect(screen.getByLabelText('Email')).toHaveValue('name@example.com');
      expect(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
      expect(screen.queryByText('9:41')).not.toBeInTheDocument();
      expect(screen.queryByText(/FPS/)).not.toBeInTheDocument();
      expect(screen.queryByText(/v0\.1/)).not.toBeInTheDocument();
    });

    it('localizes the preview screen', () => {
      render(
        <ThemeStudioProvider>
          <StudioPreview lang="id" />
        </ThemeStudioProvider>
      );

      expect(screen.getByText('Detail pengiriman')).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Simpan' })
      ).toBeInTheDocument();
    });

    it('feeds the resolved palette to the components as --just-* tokens', () => {
      render(
        <ThemeStudioProvider initialSeedColor="#e11d48">
          <StudioPreview lang="en" />
        </ThemeStudioProvider>
      );

      const scope = screen.getByTestId('studio-preview')
        .firstElementChild as HTMLElement;
      expect(scope.style.getPropertyValue('--just-accent')).toBe('#e11d48');
    });

    it('supports the switch inside the preview', () => {
      render(
        <ThemeStudioProvider>
          <StudioPreview lang="en" />
        </ThemeStudioProvider>
      );

      const previewSwitch = screen.getByRole('switch');
      expect(previewSwitch).toHaveAttribute('aria-checked', 'true');
      fireEvent.click(previewSwitch);
      expect(previewSwitch).toHaveAttribute('aria-checked', 'false');
    });
  });

  describe('CodeExportDrawer Organism & Syntax Highlighter', () => {
    it('renders YAML tab by default', () => {
      render(
        <ThemeStudioProvider>
          <CodeExportDrawer lang="en" />
        </ThemeStudioProvider>
      );

      // File names are the tab labels: one header, no second file-name bar.
      expect(
        screen.getByRole('tab', { name: 'justui.config.yaml' })
      ).toHaveAttribute('aria-selected', 'true');
      expect(
        screen.getByRole('tab', { name: 'theme.dart' })
      ).toBeInTheDocument();
      expect(screen.getByRole('tab', { name: 'terminal' })).toBeInTheDocument();
      expect(screen.getAllByText('justui.config.yaml')).toHaveLength(1);
    });

    it('switches between YAML, Dart, and CLI tabs', () => {
      render(
        <ThemeStudioProvider>
          <CodeExportDrawer lang="en" />
        </ThemeStudioProvider>
      );

      const dartTab = screen.getByRole('tab', { name: 'theme.dart' });
      fireEvent.click(dartTab);

      expect(screen.getByTestId('code-export-panel')).toHaveTextContent(
        'JustThemeData.fromSeed('
      );

      const cliTab = screen.getByRole('tab', { name: 'terminal' });
      fireEvent.click(cliTab);

      expect(screen.getByTestId('code-export-panel')).toHaveTextContent(
        'justui init --preset default --color-space hsl'
      );
    });

    it('links tabs to the code panel with ARIA attributes', () => {
      render(
        <ThemeStudioProvider>
          <CodeExportDrawer lang="en" />
        </ThemeStudioProvider>
      );

      const panel = screen.getByRole('tabpanel');
      const yamlTab = screen.getByRole('tab', { name: 'justui.config.yaml' });
      const dartTab = screen.getByRole('tab', { name: 'theme.dart' });

      expect(yamlTab).toHaveAttribute('aria-controls', panel.id);
      expect(panel).toHaveAttribute('aria-labelledby', yamlTab.id);
      expect(yamlTab).toHaveAttribute('tabindex', '0');
      expect(dartTab).toHaveAttribute('tabindex', '-1');
      expect(panel).toHaveTextContent('preset: default');
    });

    it('moves between tabs with arrow, Home and End keys', () => {
      render(
        <ThemeStudioProvider>
          <CodeExportDrawer lang="en" />
        </ThemeStudioProvider>
      );

      const yamlTab = screen.getByRole('tab', { name: 'justui.config.yaml' });
      const dartTab = screen.getByRole('tab', { name: 'theme.dart' });
      const cliTab = screen.getByRole('tab', { name: 'terminal' });

      fireEvent.keyDown(yamlTab, { key: 'ArrowRight' });
      expect(dartTab).toHaveAttribute('aria-selected', 'true');
      expect(dartTab).toHaveFocus();

      fireEvent.keyDown(dartTab, { key: 'End' });
      expect(cliTab).toHaveAttribute('aria-selected', 'true');

      fireEvent.keyDown(cliTab, { key: 'ArrowRight' });
      expect(yamlTab).toHaveAttribute('aria-selected', 'true');

      fireEvent.keyDown(yamlTab, { key: 'ArrowLeft' });
      expect(cliTab).toHaveAttribute('aria-selected', 'true');

      fireEvent.keyDown(cliTab, { key: 'Home' });
      expect(yamlTab).toHaveAttribute('aria-selected', 'true');
      expect(screen.getByRole('tabpanel')).toHaveTextContent(
        'components_dir: lib/widgets'
      );
    });
  });

  describe('Toolbar Actions (Reset & Share)', () => {
    it('resets state when Reset button is clicked', () => {
      render(
        <PresetProvider>
          <StudioClient lang="en" initialPreset="neobrutalism" />
        </PresetProvider>
      );

      expect(screen.getByText('neobrutalism')).toBeInTheDocument();
      fireEvent.change(screen.getByLabelText('Seed color as hex'), {
        target: { value: '#3b82f6' },
      });

      fireEvent.click(screen.getByRole('button', { name: 'Reset' }));

      expect(screen.getByLabelText('Seed color as hex')).toHaveValue('#a3e635');
      expect(screen.getByText('default')).toBeInTheDocument();
    });

    it('triggers clipboard write on Share button click', async () => {
      render(<StudioClient lang="en" />);

      const shareButton = screen.getByRole('button', { name: 'Share' });
      fireEvent.click(shareButton);

      expect(navigator.clipboard.writeText).toHaveBeenCalled();
    });
  });

  describe('StudioPage Server Component & Route', () => {
    it('generates static params for all supported locales', async () => {
      const params = await generateStaticParams();
      expect(params).toEqual([{ lang: 'en' }, { lang: 'id' }]);
    });

    it('generates metadata correctly for en and id', async () => {
      const metaEn = await generateMetadata({
        params: Promise.resolve({ lang: 'en' }),
      });
      expect(metaEn.title).toContain('Theme Studio');

      const metaId = await generateMetadata({
        params: Promise.resolve({ lang: 'id' }),
      });
      expect(metaId.title).toContain('Theme Studio');
    });

    it('renders server page layout with navbar and footer', async () => {
      const page = await StudioPage({
        params: Promise.resolve({ lang: 'en' }),
        searchParams: Promise.resolve({}),
      });
      render(page);

      expect(screen.getByRole('banner')).toBeInTheDocument();
      expect(screen.getByRole('main')).toBeInTheDocument();
      expect(screen.getByRole('contentinfo')).toBeInTheDocument();
    });

    it('applies seed/dark/preset/colorSpace from searchParams on the very first render, with no flash of the default theme', async () => {
      // window.location.search is empty per beforeEach, so the client-side
      // effect that reads it cannot be what produces this value -- only a
      // correctly-threaded server prop can.
      const page = await StudioPage({
        params: Promise.resolve({ lang: 'en' }),
        searchParams: Promise.resolve({
          seed: 'e11d48',
          dark: '1',
          preset: 'neo',
          cs: 'oklch',
        }),
      });
      render(page);

      expect(screen.getByLabelText('Seed color as hex')).toHaveValue('#e11d48');
      // "Dark" (not "Light") confirms the label is already reflecting the
      // resolved isDark=true state on this very first render.
      expect(screen.getByRole('switch', { name: 'Dark' })).toHaveAttribute(
        'aria-checked',
        'true'
      );
      expect(screen.getByText('neobrutalism')).toBeInTheDocument();
    });
  });
});

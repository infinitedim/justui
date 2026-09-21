import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { StudioClient } from '@/app/[lang]/studio/studio-client';
import StudioPage, {
  generateMetadata,
  generateStaticParams,
} from '@/app/[lang]/studio/page';
import { ThemeConfigurator } from '@/components/organisms/theme-configurator';
import { PhoneMockupCanvas } from '@/components/organisms/phone-mockup-canvas';
import { CodeExportDrawer } from '@/components/organisms/code-export-drawer';
import { CodeHighlighter } from '@/components/organisms/code-export-drawer/code-highlighter';
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
      expect(screen.getByTestId('phone-mockup-canvas')).toBeInTheDocument();
      expect(screen.getByTestId('code-export-drawer')).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 1, name: 'Theme Studio' })).toBeInTheDocument();
    });

    it('renders localized content when lang is id (Indonesian)', () => {
      render(<StudioClient lang="id" />);

      expect(screen.getByText('Konfigurasi design token secara visual dan ekspor kode siap produksi.')).toBeInTheDocument();
      expect(screen.getByText('Warna Dasar')).toBeInTheDocument();
      expect(screen.getByText('Ruang Warna')).toBeInTheDocument();
    });
  });

  describe('ThemeConfigurator Organism', () => {
    it('renders seed color input and preset swatches', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      expect(screen.getByLabelText('Hex color string')).toHaveValue('#a3e635');
      expect(screen.getByText('Lime')).toBeInTheDocument();
      expect(screen.getByText('Blue')).toBeInTheDocument();
      expect(screen.getByText('Rose')).toBeInTheDocument();
    });

    it('updates seed color when a preset swatch is clicked', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const blueSwatch = screen.getByText('Blue');
      fireEvent.click(blueSwatch);

      const input = screen.getByLabelText('Hex color string');
      expect(input).toHaveValue('#3b82f6');
    });

    it('normalizes hex input on blur', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const input = screen.getByLabelText('Hex color string');
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
      expect(screen.getByLabelText('Hex color string')).toHaveValue('#000000');

      // Drag back to 55%
      fireEvent.change(slider, { target: { value: '55' } });
      // Should recover lime tone, not stay black/gray
      const val = (screen.getByLabelText('Hex color string') as HTMLInputElement).value;
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

    it('allows switching presets between default and neobrutalism', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      const neoRadio = screen.getByRole('radio', { name: 'Neobrutalism' });
      fireEvent.click(neoRadio);

      expect(neoRadio).toHaveAttribute('aria-checked', 'true');
    });

    it('renders resolved palette tokens with WCAG contrast badges', () => {
      render(
        <ThemeStudioProvider>
          <ThemeConfigurator lang="en" />
        </ThemeStudioProvider>
      );

      expect(screen.getByText('Resolved Palette')).toBeInTheDocument();
      expect(screen.getByText('Primary Text')).toBeInTheDocument();
      expect(screen.getByText('Card Surface')).toBeInTheDocument();
    });
  });

  describe('PhoneMockupCanvas Organism', () => {
    it('renders device frame with status bar and app header', () => {
      render(
        <ThemeStudioProvider>
          <PhoneMockupCanvas lang="en" />
        </ThemeStudioProvider>
      );

      expect(screen.getByText('9:41')).toBeInTheDocument();
      expect(screen.getByText('JustUI App')).toBeInTheDocument();
      expect(screen.getByText('Welcome back')).toBeInTheDocument();
      expect(screen.getByText('Get Started')).toBeInTheDocument();
      expect(screen.getByText('120 FPS')).toBeInTheDocument();
    });

    it('supports interactive switch toggle inside phone mockup', () => {
      render(
        <ThemeStudioProvider>
          <PhoneMockupCanvas lang="en" />
        </ThemeStudioProvider>
      );

      const mockupSwitch = screen.getByRole('switch');
      expect(mockupSwitch).toHaveAttribute('aria-checked', 'true');

      fireEvent.click(mockupSwitch);
      expect(mockupSwitch).toHaveAttribute('aria-checked', 'false');
    });
  });

  describe('CodeExportDrawer Organism & Syntax Highlighter', () => {
    it('renders YAML tab by default', () => {
      render(
        <ThemeStudioProvider>
          <CodeExportDrawer lang="en" />
        </ThemeStudioProvider>
      );

      expect(screen.getByText('justui.config.yaml')).toBeInTheDocument();
      expect(screen.getByText('Config YAML')).toBeInTheDocument();
      expect(screen.getByText('Dart Code')).toBeInTheDocument();
      expect(screen.getByText('CLI Command')).toBeInTheDocument();
    });

    it('switches between YAML, Dart, and CLI tabs', () => {
      render(
        <ThemeStudioProvider>
          <CodeExportDrawer lang="en" />
        </ThemeStudioProvider>
      );

      const dartTab = screen.getByRole('tab', { name: 'Dart Code' });
      fireEvent.click(dartTab);

      expect(screen.getByText('theme.dart')).toBeInTheDocument();
      expect(screen.getByText('JustThemeData')).toBeInTheDocument();

      const cliTab = screen.getByRole('tab', { name: 'CLI Command' });
      fireEvent.click(cliTab);

      expect(screen.getByText('Terminal')).toBeInTheDocument();
      expect(screen.getByText('justui')).toBeInTheDocument();
    });

    it('syntax highlighter marks tokens with data-token attributes', () => {
      const { container } = render(
        <CodeHighlighter
          code="final theme = JustThemeData.fromSeed(const Color(0xFFA3E635));"
          language="dart"
        />
      );

      const keywords = container.querySelectorAll('[data-token="keyword"]');
      expect(keywords.length).toBeGreaterThanOrEqual(1);

      const types = container.querySelectorAll('[data-token="type"]');
      expect(types.length).toBeGreaterThanOrEqual(1);
    });

    it('syntax highlighter handles YAML keys and comments', () => {
      const { container } = render(
        <CodeHighlighter
          code={`# Config comment\npreset: default\ncolor_space: hsl`}
          language="yaml"
        />
      );

      const comments = container.querySelectorAll('[data-token="comment"]');
      expect(comments.length).toBe(1);

      const keys = container.querySelectorAll('[data-token="key"]');
      expect(keys.length).toBe(2);
    });

    it('syntax highlighter highlights Dart named arguments with key tokens', () => {
      const { container } = render(
        <CodeHighlighter
          code={`final theme = JustThemeData.fromSeed(\n  const Color(0xFFA3E635),\n  isDark: true,\n  preset: .neobrutalism,\n);`}
          language="dart"
        />
      );

      const keys = container.querySelectorAll('[data-token="key"]');
      expect(keys.length).toBe(2);
      expect(keys[0]?.textContent).toBe('isDark');
      expect(keys[1]?.textContent).toBe('preset');
    });

    it('syntax highlighter handles CLI comments and prompt', () => {
      const { container } = render(
        <CodeHighlighter
          code={`# JustUI CLI\n$ justui init --preset default`}
          language="cli"
        />
      );

      const comments = container.querySelectorAll('[data-token="comment"]');
      expect(comments.length).toBe(1);

      const commands = container.querySelectorAll('[data-token="command"]');
      expect(commands.length).toBe(1);
      expect(commands[0]?.textContent).toBe('justui');
    });
  });

  describe('Toolbar Actions (Reset & Share)', () => {
    it('resets state when Reset button is clicked', () => {
      render(<StudioClient lang="en" />);

      // Change preset to neobrutalism
      const neoRadio = screen.getByRole('radio', { name: 'Neobrutalism' });
      fireEvent.click(neoRadio);
      expect(neoRadio).toHaveAttribute('aria-checked', 'true');

      // Click Reset button in top toolbar
      const resetButton = screen.getByRole('button', { name: 'Reset' });
      fireEvent.click(resetButton);

      // Verify preset returned to default
      const defaultRadio = screen.getByRole('radio', { name: 'Default' });
      expect(defaultRadio).toHaveAttribute('aria-checked', 'true');
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
      });
      render(page);

      expect(screen.getByRole('banner')).toBeInTheDocument();
      expect(screen.getByRole('main')).toBeInTheDocument();
      expect(screen.getByRole('contentinfo')).toBeInTheDocument();
    });
  });
});

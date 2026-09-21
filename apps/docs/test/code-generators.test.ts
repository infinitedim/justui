import { describe, expect, it } from 'vitest';
import {
  generateYaml,
  generateDart,
  generateCli,
  seedToArgbHex,
} from '@/components/organisms/code-export-drawer/code-generators';

describe('Code Generators', () => {
  describe('seedToArgbHex', () => {
    it('converts 6-character hex to 32-bit ARGB hex', () => {
      expect(seedToArgbHex('#a3e635')).toBe('0xFFA3E635');
      expect(seedToArgbHex('#3b82f6')).toBe('0xFF3B82F6');
      expect(seedToArgbHex('#000000')).toBe('0xFF000000');
      expect(seedToArgbHex('#ffffff')).toBe('0xFFFFFFFF');
    });

    it('converts 3-character hex shorthand to 32-bit ARGB hex', () => {
      expect(seedToArgbHex('#fff')).toBe('0xFFFFFFFF');
      expect(seedToArgbHex('#000')).toBe('0xFF000000');
    });

    it('falls back safely for invalid input', () => {
      expect(seedToArgbHex('invalid')).toBe('0xFFA3E635');
    });
  });

  describe('generateYaml', () => {
    it('generates standard YAML with default values', () => {
      const yaml = generateYaml({
        preset: 'default',
        colorSpace: 'hsl',
      });

      expect(yaml).toContain('components_dir: lib/widgets');
      expect(yaml).toContain('tokens_dir: lib/tokens');
      expect(yaml).toContain('shared_dir: lib/widgets/shared');
      expect(yaml).toContain('registry_url: https://raw.githubusercontent.com/infinitedim/justui/main/registry');
      expect(yaml).toContain('preset: default');
      expect(yaml).toContain('color_space: hsl');
      expect(yaml).toContain('dart_target: standard');
    });

    it('embeds custom share URL as a comment', () => {
      const shareUrl = 'https://justui.dev/en/studio?seed=f43f5e&dark=1&preset=neo&cs=oklch';
      const yaml = generateYaml(
        { preset: 'neobrutalism', colorSpace: 'oklch' },
        shareUrl
      );

      expect(yaml).toContain(`# ${shareUrl}`);
      expect(yaml).toContain('preset: neobrutalism');
      expect(yaml).toContain('color_space: oklch');
    });

    it('produces only pure ASCII characters', () => {
      const yaml = generateYaml({ preset: 'default', colorSpace: 'hsl' });
      for (let i = 0; i < yaml.length; i++) {
        expect(yaml.charCodeAt(i)).toBeLessThanOrEqual(127);
      }
    });
  });

  describe('generateDart', () => {
    it('generates compact fromSeed without defaults when using default values', () => {
      const dart = generateDart({
        seedColor: '#a3e635',
        isDark: false,
        preset: 'default',
        colorSpace: 'hsl',
      });

      expect(dart).toContain("import 'package:flutter/widgets.dart' show Color;");
      expect(dart).toContain("import 'package:just_ui_core/just_ui_core.dart';");
      expect(dart).toContain('final theme = JustThemeData.fromSeed(');
      expect(dart).toContain('const Color(0xFFA3E635),');
      expect(dart).not.toContain('isDark:');
      expect(dart).not.toContain('preset:');
      expect(dart).not.toContain('colorSpace:');
    });

    it('includes non-default parameters when customized', () => {
      const dart = generateDart({
        seedColor: '#3b82f6',
        isDark: true,
        preset: 'neobrutalism',
        colorSpace: 'oklch',
      });

      expect(dart).toContain('const Color(0xFF3B82F6),');
      expect(dart).toContain('isDark: true,');
      expect(dart).toContain('preset: .neobrutalism,');
      expect(dart).toContain('colorSpace: .oklch,');
    });

    it('uses dot shorthand .default_ and .hsl when includeDefaults is true', () => {
      const dart = generateDart(
        {
          seedColor: '#a3e635',
          isDark: false,
          preset: 'default',
          colorSpace: 'hsl',
        },
        { includeDefaults: true }
      );

      expect(dart).toContain('isDark: false,');
      expect(dart).toContain('preset: .default_,');
      expect(dart).toContain('colorSpace: .hsl,');
    });

    it('produces only pure ASCII characters', () => {
      const dart = generateDart({
        seedColor: '#a3e635',
        isDark: true,
        preset: 'neobrutalism',
        colorSpace: 'hsluv',
      });
      for (let i = 0; i < dart.length; i++) {
        expect(dart.charCodeAt(i)).toBeLessThanOrEqual(127);
      }
    });
  });

  describe('generateCli', () => {
    it('generates standard init command with flags', () => {
      const cli = generateCli({ preset: 'default', colorSpace: 'hsl' });
      expect(cli).toBe('justui init --preset default --color-space hsl');
    });

    it('generates custom preset and color space flags', () => {
      const cli = generateCli({
        preset: 'neobrutalism',
        colorSpace: 'oklch',
      });
      expect(cli).toBe('justui init --preset neobrutalism --color-space oklch');
    });

    it('produces only pure ASCII characters', () => {
      const cli = generateCli({ preset: 'neobrutalism', colorSpace: 'hsluv' });
      for (let i = 0; i < cli.length; i++) {
        expect(cli.charCodeAt(i)).toBeLessThanOrEqual(127);
      }
    });
  });
});

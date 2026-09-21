import { describe, expect, it } from 'vitest';
import {
  hexToRgb,
  rgbToHex,
  hexToHsl,
  hslToHex,
  relativeLuminance,
  contrastRatio,
  adjustLightnessForContrast,
  generateDarkSurface,
  resolveTokens,
  normalizeHex,
} from '@/lib/theme/color-resolver';
import {
  serializeStudioState,
  deserializeStudioState,
  buildShareUrl,
} from '@/lib/theme/url-serializer';

describe('Color Resolver Engine', () => {
  describe('Hex and RGB conversions', () => {
    it('converts standard 6-character hex to RGB', () => {
      expect(hexToRgb('#ffffff')).toEqual([255, 255, 255]);
      expect(hexToRgb('#000000')).toEqual([0, 0, 0]);
      expect(hexToRgb('#ff0000')).toEqual([255, 0, 0]);
      expect(hexToRgb('#00ff00')).toEqual([0, 255, 0]);
      expect(hexToRgb('#0000ff')).toEqual([0, 0, 255]);
    });

    it('converts 3-character hex shorthand to RGB', () => {
      expect(hexToRgb('#fff')).toEqual([255, 255, 255]);
      expect(hexToRgb('#000')).toEqual([0, 0, 0]);
      expect(hexToRgb('#f00')).toEqual([255, 0, 0]);
    });

    it('handles 8-character ARGB hex by extracting RGB', () => {
      expect(normalizeHex('0xffa3e635')).toBe('#a3e635');
      expect(normalizeHex('#ffa3e635')).toBe('#a3e635');
    });

    it('falls back safely on invalid hex strings', () => {
      expect(normalizeHex('invalid')).toBe('#a3e635');
      expect(hexToRgb('xyz')).toEqual([163, 230, 53]);
    });

    it('converts RGB components back to 6-character hex', () => {
      expect(rgbToHex(255, 255, 255)).toBe('#ffffff');
      expect(rgbToHex(0, 0, 0)).toBe('#000000');
      expect(rgbToHex(163, 230, 53)).toBe('#a3e635');
    });

    it('clamps out of bounds RGB values', () => {
      expect(rgbToHex(-10, 300, 128)).toBe('#00ff80');
    });
  });

  describe('HSL and Hex conversions', () => {
    it('converts primary seed colors to HSL and back', () => {
      const colors = ['#a3e635', '#3b82f6', '#f43f5e', '#f59e0b', '#8b5cf6', '#06b6d4'];
      for (const hex of colors) {
        const [h, s, l] = hexToHsl(hex);
        expect(h).toBeGreaterThanOrEqual(0);
        expect(h).toBeLessThanOrEqual(360);
        expect(s).toBeGreaterThanOrEqual(0);
        expect(s).toBeLessThanOrEqual(100);
        expect(l).toBeGreaterThanOrEqual(0);
        expect(l).toBeLessThanOrEqual(100);

        const roundTripHex = hslToHex(h, s, l);
        const [r1, g1, b1] = hexToRgb(hex);
        const [r2, g2, b2] = hexToRgb(roundTripHex);
        expect(Math.abs(r1 - r2)).toBeLessThanOrEqual(2);
        expect(Math.abs(g1 - g2)).toBeLessThanOrEqual(2);
        expect(Math.abs(b1 - b2)).toBeLessThanOrEqual(2);
      }
    });

    it('handles grayscale values in HSL conversions', () => {
      const [whiteH, whiteS, whiteL] = hexToHsl('#ffffff');
      expect(whiteL).toBe(100);
      expect(hslToHex(whiteH, whiteS, whiteL)).toBe('#ffffff');

      const [blackH, blackS, blackL] = hexToHsl('#000000');
      expect(blackL).toBe(0);
      expect(hslToHex(blackH, blackS, blackL)).toBe('#000000');
    });
  });

  describe('Luminance and Contrast Ratios', () => {
    it('computes expected relative luminance for pure white and black', () => {
      expect(relativeLuminance('#ffffff')).toBeCloseTo(1.0, 4);
      expect(relativeLuminance('#000000')).toBeCloseTo(0.0, 4);
    });

    it('computes 21:1 contrast ratio between pure black and white', () => {
      expect(contrastRatio('#000000', '#ffffff')).toBe(21);
      expect(contrastRatio('#ffffff', '#000000')).toBe(21);
    });

    it('computes 1:1 contrast ratio for identical colors', () => {
      expect(contrastRatio('#a3e635', '#a3e635')).toBe(1);
    });

    it('adjusts lightness dynamically to meet target contrast ratio', () => {
      const lightBg = '#ffffff';
      const lowContrastFg = '#bef264';
      const adjusted = adjustLightnessForContrast(lowContrastFg, lightBg, 3.0);
      expect(contrastRatio(adjusted, lightBg)).toBeGreaterThanOrEqual(3.0);
    });

    it('does not alter colors that already satisfy minimum contrast ratio', () => {
      const bg = '#ffffff';
      const fg = '#000000';
      expect(adjustLightnessForContrast(fg, bg, 3.0)).toBe('#000000');
    });
  });

  describe('Dark Surface Generation', () => {
    it('generates dark surfaces with subtle hue tint', () => {
      const darkBg = generateDarkSurface('#a3e635', 3);
      const darkCard = generateDarkSurface('#a3e635', 7);

      expect(darkBg.startsWith('#')).toBe(true);
      expect(darkCard.startsWith('#')).toBe(true);

      const [, , lBg] = hexToHsl(darkBg);
      const [, , lCard] = hexToHsl(darkCard);
      expect(lBg).toBeLessThan(lCard);
    });
  });

  describe('Token Resolution', () => {
    it('resolves tokens for default light preset', () => {
      const tokens = resolveTokens('#a3e635', false, 'default', 'hsl');

      expect(tokens.background).toBe('#f8fafc');
      expect(tokens.card).toBe('#ffffff');
      expect(tokens.textPrimary).toBe('#18181b');
      expect(tokens.borderWidth).toBe('1px');
      expect(tokens.shadowSolid).toBe('none');
      expect(tokens.radiusMd).toBe('8px');
      expect(tokens.radiusLg).toBe('12px');
      expect(tokens.accent).toBe('#a3e635');
    });

    it('resolves tokens for dark mode', () => {
      const tokens = resolveTokens('#a3e635', true, 'default', 'hsl');

      expect(tokens.textPrimary).toBe('#f8fafc');
      expect(tokens.textSecondary).toBe('#a1a1aa');
      expect(tokens.border).toBe('#27272a');
      expect(relativeLuminance(tokens.background)).toBeLessThan(0.05);
    });

    it('resolves tokens for neobrutalism preset', () => {
      const lightTokens = resolveTokens('#a3e635', false, 'neobrutalism', 'hsl');

      expect(lightTokens.background).toBe('#fffdf5');
      expect(lightTokens.border).toBe('#18181b');
      expect(lightTokens.borderWidth).toBe('2.5px');
      expect(lightTokens.shadowSolid).toBe('4px 4px 0px #18181b');
      expect(lightTokens.radiusMd).toBe('0px');
      expect(lightTokens.radiusLg).toBe('0px');

      const darkTokens = resolveTokens('#a3e635', true, 'neobrutalism', 'hsl');
      expect(darkTokens.border).toBe('#ffffff');
      expect(darkTokens.shadowSolid).toBe('4px 4px 0px #ffffff');
    });

    it('enforces WCAG contrast for state colors against background in light and dark modes', () => {
      const lightTokens = resolveTokens('#a3e635', false, 'default', 'hsl');
      expect(contrastRatio(lightTokens.success, lightTokens.background)).toBeGreaterThanOrEqual(4.5);
      expect(contrastRatio(lightTokens.warning, lightTokens.background)).toBeGreaterThanOrEqual(3.0);
      expect(contrastRatio(lightTokens.error, lightTokens.background)).toBeGreaterThanOrEqual(4.5);

      const darkTokens = resolveTokens('#a3e635', true, 'default', 'hsl');
      expect(contrastRatio(darkTokens.success, darkTokens.background)).toBeGreaterThanOrEqual(4.5);
      expect(contrastRatio(darkTokens.warning, darkTokens.background)).toBeGreaterThanOrEqual(3.0);
      expect(contrastRatio(darkTokens.error, darkTokens.background)).toBeGreaterThanOrEqual(4.5);
    });
  });

  describe('URL Serialization & Deserialization', () => {
    it('serializes state to expected query parameters', () => {
      const state = {
        seedColor: '#a3e635',
        isDark: false,
        preset: 'default' as const,
        colorSpace: 'hsl' as const,
      };

      const query = serializeStudioState(state);
      expect(query).toBe('seed=a3e635&dark=0&preset=def&cs=hsl');
    });

    it('serializes dark neobrutalism state with oklch', () => {
      const state = {
        seedColor: '#3b82f6',
        isDark: true,
        preset: 'neobrutalism' as const,
        colorSpace: 'oklch' as const,
      };

      const query = serializeStudioState(state);
      expect(query).toBe('seed=3b82f6&dark=1&preset=neo&cs=oklch');
    });

    it('deserializes query string accurately', () => {
      const query = 'seed=3b82f6&dark=1&preset=neo&cs=oklch';
      const parsed = deserializeStudioState(query);

      expect(parsed.seedColor).toBe('#3b82f6');
      expect(parsed.isDark).toBe(true);
      expect(parsed.preset).toBe('neobrutalism');
      expect(parsed.colorSpace).toBe('oklch');
    });

    it('expands 3-character hex shorthand to standard 6-digit hex on deserialization', () => {
      const parsed = deserializeStudioState('seed=fff');
      expect(parsed.seedColor).toBe('#ffffff');
    });

    it('rejects invalid seed hex strings during deserialization', () => {
      const parsed = deserializeStudioState('seed=1234');
      expect(parsed.seedColor).toBeUndefined();

      const parsedInvalid = deserializeStudioState('seed=xyz');
      expect(parsedInvalid.seedColor).toBeUndefined();
    });

    it('handles missing or partial query parameters safely', () => {
      const parsed = deserializeStudioState('seed=f43f5e');
      expect(parsed.seedColor).toBe('#f43f5e');
      expect(parsed.isDark).toBeUndefined();
      expect(parsed.preset).toBeUndefined();
    });

    it('constructs shareable URL cleanly', () => {
      const url = buildShareUrl('https://justui.dev/en/studio', {
        seedColor: '#a3e635',
        isDark: false,
        preset: 'default',
        colorSpace: 'hsl',
      });

      expect(url).toBe(
        'https://justui.dev/en/studio?seed=a3e635&dark=0&preset=def&cs=hsl'
      );
    });
  });
});

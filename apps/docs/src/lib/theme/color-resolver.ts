import type { JustUIPreset } from '../presets';
import {
  type ColorSpace,
  fromPerceptual,
  hexToHsl,
  hexToRgb,
  hslToHex,
  normalizeHex,
  rgbToHex,
  toPerceptual,
} from './perceptual';

export type { JustUIPreset };
export type { ColorSpace, PerceptualColor } from './perceptual';
export {
  normalizeHex,
  hexToRgb,
  rgbToHex,
  hexToHsl,
  hslToHex,
  toPerceptual,
  fromPerceptual,
};

export interface ResolvedTokens {
  background: string;
  card: string;
  textPrimary: string;
  textSecondary: string;
  accent: string;
  accentForeground: string;
  /** Accent used as text on `card`; always >= 4.5:1 (WCAG AA body text). */
  accentText: string;
  border: string;
  borderWidth: string;
  shadowSolid: string;
  success: string;
  warning: string;
  error: string;
  radiusMd: string;
  radiusLg: string;
  /** Transform applied while a solid control is pressed. */
  pressTransform: string;
}

/**
 * Computes standard WCAG 2.0 relative luminance of a color.
 */
export function relativeLuminance(hex: string): number {
  const [r, g, b] = hexToRgb(hex);
  const srgb = [r / 255, g / 255, b / 255].map((val) =>
    val <= 0.04045 ? val / 12.92 : Math.pow((val + 0.055) / 1.055, 2.4)
  );
  return (
    0.2126 * (srgb[0] ?? 0) + 0.7152 * (srgb[1] ?? 0) + 0.0722 * (srgb[2] ?? 0)
  );
}

/**
 * Computes WCAG 2.0 contrast ratio between two colors (range 1.0 to 21.0).
 * Returns exact floating-point ratio without premature rounding to avoid
 * false-positive accessibility validations.
 */
export function contrastRatio(color1: string, color2: string): number {
  const l1 = relativeLuminance(color1);
  const l2 = relativeLuminance(color2);
  return (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);
}

/**
 * Adjusts lightness of fg color to guarantee at least minRatio contrast against bg.
 * Uses binary search in the selected perceptual color space.
 */
export function adjustLightnessForContrast(
  fg: string,
  bg: string,
  minRatio = 3.0,
  engine: ColorSpace = 'hsl'
): string {
  if (contrastRatio(fg, bg) >= minRatio) {
    return normalizeHex(fg);
  }

  const bgLum = relativeLuminance(bg);
  const pc = toPerceptual(fg, engine);
  const makeLighter = bgLum < 0.5;

  let low = makeLighter ? pc.l : 0.0;
  let high = makeLighter ? 1.0 : pc.l;
  let bestHex = normalizeHex(fg);

  for (let i = 0; i < 16; i++) {
    const mid = (low + high) / 2;
    const testHex = fromPerceptual({ l: mid, c: pc.c, h: pc.h }, engine);
    const ratio = contrastRatio(testHex, bg);

    if (ratio >= minRatio) {
      bestHex = testHex;
      if (makeLighter) {
        high = mid;
      } else {
        low = mid;
      }
    } else {
      if (makeLighter) {
        low = mid;
      } else {
        high = mid;
      }
    }
  }

  if (contrastRatio(bestHex, bg) >= minRatio) {
    return bestHex;
  }

  // Fallback to pure white or black if target ratio cannot be reached in-gamut
  return makeLighter ? '#ffffff' : '#000000';
}

/**
 * Generates a subtly tinted dark surface from seed hue and target lightness percentage.
 * Damps chroma in the selected color space matching Flutter JustDynamicSurfaces.
 */
export function generateDarkSurface(
  seedHex: string,
  lightnessPercent = 3,
  engine: ColorSpace = 'hsl'
): string {
  const pc = toPerceptual(seedHex, engine);
  const dampedC = Math.max(0.0, Math.min(0.12, pc.c * 0.2));
  const lightness = Math.max(0.01, Math.min(0.25, lightnessPercent / 100.0));
  return fromPerceptual({ l: lightness, c: dampedC, h: pc.h }, engine);
}

/**
 * Resolves all design tokens from seed color, mode, preset, and color space.
 */
export function resolveTokens(
  seedColor: string,
  isDark: boolean,
  preset: JustUIPreset = 'default',
  colorSpace: ColorSpace = 'hsl'
): ResolvedTokens {
  const normSeed = normalizeHex(seedColor);
  const isNeo = preset === 'neobrutalism';

  // Surface and text colors
  let background: string;
  let card: string;
  let textPrimary: string;
  let textSecondary: string;

  if (isDark) {
    background = isNeo ? '#1a1a1a' : generateDarkSurface(normSeed, 3, colorSpace);
    card = isNeo ? '#262626' : generateDarkSurface(normSeed, 7, colorSpace);
    textPrimary = isNeo ? '#ffffff' : '#f8fafc';
    textSecondary = isNeo ? '#cccccc' : '#a1a1aa';
  } else {
    background = isNeo ? '#fff8e7' : '#f8fafc';
    card = '#ffffff';
    textPrimary = isNeo ? '#000000' : '#18181b';
    textSecondary = isNeo ? '#222222' : '#4f4f4f';
  }

  // Accent & readable foreground
  const accent = normSeed;
  const contrastWithWhite = contrastRatio(accent, '#ffffff');
  const contrastWithDark = contrastRatio(accent, isNeo ? '#000000' : '#18181b');
  const accentForeground = isNeo
    ? '#000000'
    : contrastWithWhite >= 4.5 || contrastWithWhite > contrastWithDark
      ? '#ffffff'
      : '#18181b';

  // Neobrutalism light prints accent text in the primary text color (mirrors
  // --just-accent-text in globals.css); otherwise darken/lighten the seed
  // until it clears 4.5:1 against the card surface.
  const accentText =
    isNeo && !isDark
      ? textPrimary
      : adjustLightnessForContrast(accent, card, 4.5, colorSpace);

  // Borders & shadows
  let border: string;
  let borderWidth: string;
  let shadowSolid: string;
  let radiusMd: string;
  let radiusLg: string;
  let pressTransform: string;

  if (isNeo) {
    border = isDark ? '#ffffff' : '#000000';
    borderWidth = '2.5px';
    shadowSolid = isDark ? '4px 4px 0px #ffffff' : '4px 4px 0px #000000';
    radiusMd = '0px';
    radiusLg = '0px';
    pressTransform = 'translate(4px, 4px)';
  } else {
    border = isDark ? '#27272a' : '#e0e0e0';
    borderWidth = '1px';
    shadowSolid = 'none';
    radiusMd = '8px';
    radiusLg = '12px';
    pressTransform = 'scale(0.97)';
  }

  // State colors (guaranteed accessible against background matching JustThemeData.fromSeed)
  const successBase = isDark ? '#4ade80' : '#22c55e';
  const warningBase = isDark ? '#fbbf24' : '#f59e0b';
  const errorBase = isDark ? '#f87171' : '#ef4444';

  const success = adjustLightnessForContrast(
    successBase,
    background,
    4.5,
    colorSpace
  );
  const warning = adjustLightnessForContrast(
    warningBase,
    background,
    3.0,
    colorSpace
  );
  const error = adjustLightnessForContrast(
    errorBase,
    background,
    4.5,
    colorSpace
  );

  return {
    background,
    card,
    textPrimary,
    textSecondary,
    accent,
    accentForeground,
    accentText,
    border,
    borderWidth,
    shadowSolid,
    success,
    warning,
    error,
    radiusMd,
    radiusLg,
    pressTransform,
  };
}

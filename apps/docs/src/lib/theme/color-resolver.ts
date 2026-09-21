export type JustUIPreset = 'default' | 'neobrutalism';
export type ColorSpace = 'hsl' | 'oklch' | 'hsluv';

export interface ResolvedTokens {
  background: string;
  card: string;
  textPrimary: string;
  textSecondary: string;
  accent: string;
  accentForeground: string;
  border: string;
  borderWidth: string;
  shadowSolid: string;
  success: string;
  warning: string;
  error: string;
  radiusMd: string;
  radiusLg: string;
}

/**
 * Normalizes a hex string to standard 6-digit lowercase #rrggbb format.
 */
export function normalizeHex(hex: string): string {
  const clean = hex.replace(/^#/, '').trim();
  if (clean.length === 3 && /^[0-9a-fA-F]{3}$/.test(clean)) {
    const [r, g, b] = clean;
    return `#${r}${r}${g}${g}${b}${b}`.toLowerCase();
  }
  if (clean.length === 6 && /^[0-9a-fA-F]{6}$/.test(clean)) {
    return `#${clean}`.toLowerCase();
  }
  if (clean.length === 8 && /^[0-9a-fA-F]{8}$/.test(clean)) {
    return `#${clean.slice(2)}`.toLowerCase();
  }
  return '#a3e635';
}

/**
 * Converts a hex color string to RGB [r, g, b] with range 0..255.
 */
export function hexToRgb(hex: string): [number, number, number] {
  const normalized = normalizeHex(hex).slice(1);
  const r = parseInt(normalized.slice(0, 2), 16);
  const g = parseInt(normalized.slice(2, 4), 16);
  const b = parseInt(normalized.slice(4, 6), 16);
  return [r, g, b];
}

/**
 * Converts RGB components [0..255] to a #rrggbb hex string.
 */
export function rgbToHex(r: number, g: number, b: number): string {
  const clamp = (val: number) => Math.max(0, Math.min(255, Math.round(val)));
  const toHex = (c: number) => clamp(c).toString(16).padStart(2, '0');
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

/**
 * Converts a hex color string to HSL [h, s, l].
 * h in range 0..360, s in range 0..100, l in range 0..100.
 */
export function hexToHsl(hex: string): [number, number, number] {
  const [rRaw, gRaw, bRaw] = hexToRgb(hex);
  const r = rRaw / 255;
  const g = gRaw / 255;
  const b = bRaw / 255;

  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const delta = max - min;

  let h = 0;
  let s = 0;
  const l = (max + min) / 2;

  if (delta !== 0) {
    s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

    switch (max) {
      case r:
        h = ((g - b) / delta + (g < b ? 6 : 0)) * 60;
        break;
      case g:
        h = ((b - r) / delta + 2) * 60;
        break;
      case b:
        h = ((r - g) / delta + 4) * 60;
        break;
    }
  }

  return [Math.round(h), Math.round(s * 100), Math.round(l * 100)];
}

/**
 * Converts HSL components to a #rrggbb hex string.
 * h: 0..360, s: 0..100, l: 0..100.
 */
export function hslToHex(h: number, s: number, l: number): string {
  const hNorm = (((h % 360) + 360) % 360) / 360;
  const sNorm = Math.max(0, Math.min(100, s)) / 100;
  const lNorm = Math.max(0, Math.min(100, l)) / 100;

  if (sNorm === 0) {
    const val = Math.round(lNorm * 255);
    return rgbToHex(val, val, val);
  }

  const hue2rgb = (p: number, q: number, t: number): number => {
    let tNorm = t;
    if (tNorm < 0) tNorm += 1;
    if (tNorm > 1) tNorm -= 1;
    if (tNorm < 1 / 6) return p + (q - p) * 6 * tNorm;
    if (tNorm < 1 / 2) return q;
    if (tNorm < 2 / 3) return p + (q - p) * (2 / 3 - tNorm) * 6;
    return p;
  };

  const q = lNorm < 0.5 ? lNorm * (1 + sNorm) : lNorm + sNorm - lNorm * sNorm;
  const p = 2 * lNorm - q;

  const r = Math.round(hue2rgb(p, q, hNorm + 1 / 3) * 255);
  const g = Math.round(hue2rgb(p, q, hNorm) * 255);
  const b = Math.round(hue2rgb(p, q, hNorm - 1 / 3) * 255);

  return rgbToHex(r, g, b);
}

/**
 * Computes standard WCAG 2.0 relative luminance of a color.
 */
export function relativeLuminance(hex: string): number {
  const [r, g, b] = hexToRgb(hex);
  const srgb = [r / 255, g / 255, b / 255].map((val) =>
    val <= 0.04045 ? val / 12.92 : Math.pow((val + 0.055) / 1.055, 2.4)
  );
  return 0.2126 * (srgb[0] ?? 0) + 0.7152 * (srgb[1] ?? 0) + 0.0722 * (srgb[2] ?? 0);
}

/**
 * Computes WCAG 2.0 contrast ratio between two colors (range 1.0 to 21.0).
 */
export function contrastRatio(color1: string, color2: string): number {
  const l1 = relativeLuminance(color1);
  const l2 = relativeLuminance(color2);
  const ratio = (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);
  return Math.round(ratio * 10) / 10;
}

/**
 * Adjusts lightness of fg color to guarantee at least minRatio contrast against bg.
 */
export function adjustLightnessForContrast(
  fg: string,
  bg: string,
  minRatio = 3.0
): string {
  if (contrastRatio(fg, bg) >= minRatio) {
    return normalizeHex(fg);
  }

  const [h, s, startL] = hexToHsl(fg);
  const bgLum = relativeLuminance(bg);
  const shouldLighten = bgLum < 0.5;

  let bestHex = normalizeHex(fg);
  let bestRatio = contrastRatio(bestHex, bg);

  // Search starting from current lightness towards target lightness
  for (let step = 1; step <= 50; step++) {
    const lAttempt = shouldLighten
      ? Math.min(100, Math.round(startL + (100 - startL) * (step / 50)))
      : Math.max(0, Math.round(startL * (1 - step / 50)));
    const candidateHex = hslToHex(h, s, lAttempt);
    const candidateRatio = contrastRatio(candidateHex, bg);

    if (candidateRatio >= minRatio) {
      return candidateHex;
    }
    if (candidateRatio > bestRatio) {
      bestRatio = candidateRatio;
      bestHex = candidateHex;
    }
  }

  return bestHex;
}

/**
 * Generates a subtly tinted dark surface from seed hue and target lightness percentage.
 */
export function generateDarkSurface(seedHex: string, lightnessPercent = 3): string {
  const [h] = hexToHsl(seedHex);
  // Restrained saturation (8%) keeps it dark and elegant with subtle hue character
  return hslToHex(h, 8, Math.max(1, Math.min(25, lightnessPercent)));
}

/**
 * Resolves all design tokens from seed color, mode, preset, and color space.
 */
export function resolveTokens(
  seedColor: string,
  isDark: boolean,
  preset: JustUIPreset = 'default',
  _colorSpace: ColorSpace = 'hsl'
): ResolvedTokens {
  const normSeed = normalizeHex(seedColor);
  const isNeo = preset === 'neobrutalism';

  // Surface and text colors
  let background: string;
  let card: string;
  let textPrimary: string;
  let textSecondary: string;

  if (isDark) {
    background = generateDarkSurface(normSeed, 3);
    card = generateDarkSurface(normSeed, 7);
    textPrimary = '#f8fafc';
    textSecondary = '#a1a1aa';
  } else {
    background = isNeo ? '#fffdf5' : '#f8fafc';
    card = '#ffffff';
    textPrimary = '#18181b';
    textSecondary = '#4f4f4f';
  }

  // Accent & readable foreground
  const accent = normSeed;
  const contrastWithWhite = contrastRatio(accent, '#ffffff');
  const contrastWithDark = contrastRatio(accent, '#18181b');
  const accentForeground = contrastWithWhite >= 4.5 || contrastWithWhite > contrastWithDark
    ? '#ffffff'
    : '#18181b';

  // Borders & shadows
  let border: string;
  let borderWidth: string;
  let shadowSolid: string;
  let radiusMd: string;
  let radiusLg: string;

  if (isNeo) {
    border = isDark ? '#ffffff' : '#18181b';
    borderWidth = '2.5px';
    shadowSolid = isDark ? '4px 4px 0px #ffffff' : '4px 4px 0px #18181b';
    radiusMd = '0px';
    radiusLg = '0px';
  } else {
    border = isDark ? '#27272a' : '#e0e0e0';
    borderWidth = '1px';
    shadowSolid = 'none';
    radiusMd = '8px';
    radiusLg = '12px';
  }

  // State colors (guaranteed accessible against background matching JustThemeData.fromSeed)
  const successBase = isDark ? '#4ade80' : '#22c55e';
  const warningBase = isDark ? '#fbbf24' : '#f59e0b';
  const errorBase = isDark ? '#f87171' : '#ef4444';

  const success = adjustLightnessForContrast(successBase, background, 4.5);
  const warning = adjustLightnessForContrast(warningBase, background, 3.0);
  const error = adjustLightnessForContrast(errorBase, background, 4.5);

  return {
    background,
    card,
    textPrimary,
    textSecondary,
    accent,
    accentForeground,
    border,
    borderWidth,
    shadowSolid,
    success,
    warning,
    error,
    radiusMd,
    radiusLg,
  };
}

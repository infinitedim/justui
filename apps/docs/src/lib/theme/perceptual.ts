/**
 * Unified perceptual color engine dispatching across HSL, OKLCH, and HSLuv.
 * Matches packages/tokens/lib/src/colors/color_space.dart.
 * Strictly 100% ASCII.
 */

import { oklchToRgb, rgbToOklch } from './oklch';
import { hsluvToRgb, rgbToHsluv } from './hsluv';

export type ColorSpace = 'hsl' | 'oklch' | 'hsluv';

export interface PerceptualColor {
  l: number;
  c: number;
  h: number;
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
 * Converts a hex color (sRGB) to normalized PerceptualColor coordinates.
 */
export function toPerceptual(hex: string, engine: ColorSpace): PerceptualColor {
  switch (engine) {
    case 'hsl': {
      const [h, s, l] = hexToHsl(hex);
      return { l: l / 100.0, c: s / 100.0, h };
    }
    case 'oklch': {
      const [r, g, b] = hexToRgb(hex);
      return rgbToOklch(r / 255.0, g / 255.0, b / 255.0);
    }
    case 'hsluv': {
      const [r, g, b] = hexToRgb(hex);
      const hsluv = rgbToHsluv(r / 255.0, g / 255.0, b / 255.0);
      return { l: hsluv.l / 100.0, c: hsluv.s / 100.0, h: hsluv.h };
    }
  }
}

/**
 * Converts normalized PerceptualColor coordinates back to a hex color (sRGB).
 */
export function fromPerceptual(
  pc: PerceptualColor,
  engine: ColorSpace
): string {
  switch (engine) {
    case 'hsl': {
      const h = Math.max(0.0, Math.min(360.0, pc.h));
      const s = Math.max(0.0, Math.min(100.0, pc.c * 100.0));
      const l = Math.max(0.0, Math.min(100.0, pc.l * 100.0));
      return hslToHex(h, s, l);
    }
    case 'oklch': {
      const l = Math.max(0.0, Math.min(1.0, pc.l));
      const c = Math.max(0.0, pc.c);
      const [r, g, b] = oklchToRgb(l, c, pc.h);
      return rgbToHex(r * 255.0, g * 255.0, b * 255.0);
    }
    case 'hsluv': {
      const h = pc.h;
      const s = Math.max(0.0, Math.min(100.0, pc.c * 100.0));
      const l = Math.max(0.0, Math.min(100.0, pc.l * 100.0));
      const [r, g, b] = hsluvToRgb(h, s, l);
      return rgbToHex(r * 255.0, g * 255.0, b * 255.0);
    }
  }
}

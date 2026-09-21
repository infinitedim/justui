import {
  normalizeHex,
  type JustUIPreset,
  type ColorSpace,
} from './color-resolver';

export interface StudioUrlParams {
  seedColor?: string;
  isDark?: boolean;
  preset?: JustUIPreset;
  colorSpace?: ColorSpace;
}

/**
 * Serializes studio state into URL query parameter string.
 * Format: seed=a3e635&dark=1&preset=neo&cs=hsl
 */
export function serializeStudioState(state: {
  seedColor: string;
  isDark: boolean;
  preset: JustUIPreset;
  colorSpace: ColorSpace;
}): string {
  const params = new URLSearchParams();

  // Compress seed color without '#' using normalized 6-char hex
  const cleanSeed = normalizeHex(state.seedColor).slice(1);
  params.set('seed', cleanSeed);

  // Binary flag for dark mode
  params.set('dark', state.isDark ? '1' : '0');

  // Compressed preset identifiers
  params.set('preset', state.preset === 'neobrutalism' ? 'neo' : 'def');

  // Color space identifier
  params.set('cs', state.colorSpace);

  return params.toString();
}

/**
 * Deserializes URL query parameter string or URLSearchParams into partial studio state.
 */
export function deserializeStudioState(
  search: string | URLSearchParams
): StudioUrlParams {
  const params =
    typeof search === 'string'
      ? new URLSearchParams(search.startsWith('?') ? search.slice(1) : search)
      : search;

  const result: StudioUrlParams = {};

  // Parse seed color strictly for 3, 6, or 8 character hex
  const seedParam = params.get('seed');
  if (seedParam) {
    const clean = seedParam.replace(/^#/, '').trim();
    if (/^(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(clean)) {
      result.seedColor = normalizeHex(clean);
    }
  }

  // Parse dark mode
  const darkParam = params.get('dark');
  if (darkParam !== null) {
    result.isDark = darkParam === '1' || darkParam.toLowerCase() === 'true';
  }

  // Parse preset
  const presetParam = params.get('preset');
  if (presetParam) {
    if (presetParam === 'neo' || presetParam === 'neobrutalism') {
      result.preset = 'neobrutalism';
    } else if (presetParam === 'def' || presetParam === 'default') {
      result.preset = 'default';
    }
  }

  // Parse color space
  const csParam = params.get('cs');
  if (csParam === 'hsl' || csParam === 'oklch' || csParam === 'hsluv') {
    result.colorSpace = csParam;
  }

  return result;
}

/**
 * Constructs a shareable absolute or relative URL with serialized studio state.
 */
export function buildShareUrl(
  baseUrl: string,
  state: {
    seedColor: string;
    isDark: boolean;
    preset: JustUIPreset;
    colorSpace: ColorSpace;
  }
): string {
  const query = serializeStudioState(state);
  const cleanBase = baseUrl.split('?')[0] ?? baseUrl;
  return `${cleanBase}?${query}`;
}

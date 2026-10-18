/**
 * Single source of truth for preset names. Values match the CLI exactly
 * (`justui init --preset neobrutalism`), so the same string is used as the
 * stored value, the URL value and the visible label.
 */
export const PRESETS = ['default', 'neobrutalism'] as const;

export type JustUIPreset = (typeof PRESETS)[number];

export const DEFAULT_PRESET: JustUIPreset = 'default';

/** Display names of the presets (product names, not translated). */
export const PRESET_LABELS = {
  default: 'Default',
  neobrutalism: 'Neobrutalism',
} as const satisfies Record<JustUIPreset, string>;

export const PRESET_OPTIONS = [
  { value: 'default', label: 'default' },
  { value: 'neobrutalism', label: 'neobrutalism' },
] as const satisfies readonly { value: JustUIPreset; label: string }[];

export function isPreset(value: unknown): value is JustUIPreset {
  return (
    typeof value === 'string' && PRESETS.some((preset) => preset === value)
  );
}

/** CSS class that applies a preset's complete token set to a subtree. */
export function presetScopeClass(preset: JustUIPreset): string {
  return preset === 'neobrutalism' ? 'theme-neobrutalism' : 'preset-default';
}

/**
 * Single source of truth for preset names. Values match the CLI exactly
 * (`justui init --preset neobrutalism`), so the same string is used as the
 * stored value, the URL value and the visible label.
 */
export const PRESETS = ['default', 'neobrutalism'] as const;

export type JustUIPreset = (typeof PRESETS)[number];

export const DEFAULT_PRESET: JustUIPreset = 'default';

export const PRESET_OPTIONS = [
  { value: 'default', label: 'default' },
  { value: 'neobrutalism', label: 'neobrutalism' },
] as const satisfies readonly { value: JustUIPreset; label: string }[];

export function isPreset(value: unknown): value is JustUIPreset {
  return (
    typeof value === 'string' && (PRESETS as readonly string[]).includes(value)
  );
}

/**
 * Parses user input the way the CLI does: `neo` and `d` are accepted aliases
 * (packages/cli/src/main.rs), everything else is rejected.
 */
export function parsePresetAlias(
  value: string | undefined
): JustUIPreset | undefined {
  const normalized = value?.trim().toLowerCase();
  if (normalized === 'neobrutalism' || normalized === 'neo') {
    return 'neobrutalism';
  }
  if (normalized === 'default' || normalized === 'd') {
    return 'default';
  }
  return undefined;
}

/** CSS class that applies a preset's complete token set to a subtree. */
export function presetScopeClass(preset: JustUIPreset): string {
  return preset === 'neobrutalism' ? 'theme-neobrutalism' : 'preset-default';
}

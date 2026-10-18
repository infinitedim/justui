import type { JustUIPreset } from '@/lib/presets';

export interface PresetSwatchProps {
  preset: JustUIPreset;
  /** Edge length in px. */
  size?: number;
  className?: string;
}

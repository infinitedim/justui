import type { JustUIPreset } from '@/lib/presets';

export interface RunnerShelfProps {
  /** Visible heading above the list. */
  heading: string;
  /** Accessible name of the radio group. */
  label: string;
  notes: Record<JustUIPreset, string>;
  className?: string;
}

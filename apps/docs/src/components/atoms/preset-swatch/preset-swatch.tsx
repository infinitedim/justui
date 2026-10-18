import { cn } from '@/lib/cn';
import type { JustUIPreset } from '@/lib/presets';
import type { PresetSwatchProps } from './preset-swatch.types';

/** Each preset is drawn as its own corner, never as a letter. */
const corners = {
  default: 'rounded-[8px] border-[1.5px]',
  neobrutalism: 'rounded-none border-[2.5px] shadow-(--ip-shadow-swatch)',
} as const satisfies Record<JustUIPreset, string>;

/** Small square that shows a preset's corner, line and shadow. */
export function PresetSwatch({
  preset,
  size = 36,
  className,
}: PresetSwatchProps) {
  return (
    <span
      aria-hidden="true"
      className={cn('shrink-0 border-current', corners[preset], className)}
      style={{ width: size, height: size }}
    />
  );
}

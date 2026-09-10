'use client';

import { cn } from '@/lib/cn';
import { Slider } from '@/components/atoms/slider';
import type { LightnessSliderProps } from './lightness-slider.types';

/**
 * HSL lightness slider molecule for the theme studio.
 * Composes the Slider atom with a lightness value label.
 */
export function LightnessSlider({
  value,
  onChange,
  label = 'Lightness',
  className,
}: LightnessSliderProps) {
  return (
    <div className={cn('flex flex-col gap-2', className)}>
      <div className="flex items-center justify-between">
        <span className="font-mono text-xs text-muted">{label}</span>
        <span className="font-mono text-xs text-foreground">{value}%</span>
      </div>
      <Slider
        value={value}
        min={0}
        max={100}
        step={1}
        label={label}
        onChange={(e) => onChange(Number(e.currentTarget.value))}
      />
    </div>
  );
}

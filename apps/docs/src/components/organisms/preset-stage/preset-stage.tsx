'use client';

// Client leaf: applies the visitor's preset to this region only.
import { usePreset } from '@/components/providers';
import { cn } from '@/lib/cn';
import { presetScopeClass } from '@/lib/presets';
import type { PresetStageProps } from './preset-stage.types';

/**
 * A stage region: the only place a preset class is applied. The page
 * chrome around it stays the same in every preset.
 */
export function PresetStage({
  preset,
  animated = true,
  className,
  children,
}: PresetStageProps) {
  const visitor = usePreset();
  const active = preset ?? visitor.preset;
  return (
    <div
      data-pbox={animated ? '' : undefined}
      data-preset={active}
      className={cn(presetScopeClass(active), className)}
    >
      {children}
    </div>
  );
}

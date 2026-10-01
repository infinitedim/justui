'use client';

import { useEffect, useState } from 'react';
import { usePreset } from '@/components/providers';
import { SegmentedToggle } from '@/components/molecules/segmented-toggle';
import { PRESET_OPTIONS } from '@/lib/presets';
import type { PresetToggleProps } from './preset-toggle.types';

/**
 * The one preset control on the site. Shows both presets by their CLI names
 * and fills the active one; the catalog, stage and Studio all read the same
 * global preset.
 */
export function PresetToggle({
  label = 'Toggle preset',
  className,
}: PresetToggleProps) {
  const { preset, setPreset } = usePreset();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  return (
    <SegmentedToggle
      label={label}
      className={className}
      value={preset}
      onChange={setPreset}
      options={PRESET_OPTIONS}
    />
  );
}

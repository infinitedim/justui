'use client';

import { useEffect, useState } from 'react';
import { usePreset } from '@/components/providers';
import { SegmentedToggle } from '@/components/molecules/segmented-toggle';
import type { PresetToggleProps } from './preset-toggle.types';

/**
 * Preset toggle molecule. Shows both presets and fills the active one, so the
 * control states what it does instead of a single ambiguous D / N letter.
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
      options={[
        { value: 'default', label: 'default' },
        { value: 'neobrutalism', label: 'neo' },
      ]}
    />
  );
}

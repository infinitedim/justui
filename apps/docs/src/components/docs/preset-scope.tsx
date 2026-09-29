'use client';

import { useState, useEffect, type ReactNode } from 'react';
import { SegmentedToggle } from '@/components/molecules/segmented-toggle';
import { usePreset, type JustUIPreset } from '@/components/providers/preset-provider';

/**
 * Local preset for a docs demo. Independent from the site-wide preset: the
 * returned `scopeClass` applies a complete token set to just that subtree.
 */
export function usePresetScope(initial?: JustUIPreset): {
  preset: JustUIPreset;
  scopeClass: string;
  toggle: ReactNode;
} {
  const global = usePreset();
  const [preset, setPreset] = useState<JustUIPreset>(initial ?? global.preset);

  useEffect(() => {
    if (initial === undefined) {
      setPreset(global.preset);
    }
  }, [global.preset, initial]);

  return {
    preset,
    scopeClass: preset === 'neobrutalism' ? 'theme-neobrutalism' : 'preset-default',
    toggle: (
      <SegmentedToggle
        label="Preview preset"
        value={preset}
        onChange={setPreset}
        options={[
          { value: 'default', label: 'default' },
          { value: 'neobrutalism', label: 'neobrutalism' },
        ]}
      />
    ),
  };
}

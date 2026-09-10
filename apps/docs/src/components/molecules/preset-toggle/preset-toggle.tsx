'use client';

import { useEffect, useState } from 'react';
import { cn } from '@/lib/cn';
import { usePreset } from '@/lib/preset-context';
import type { PresetToggleProps } from './preset-toggle.types';

/**
 * Preset toggle molecule. Switches between default and neobrutalism presets.
 * Extracted from the old navbar PresetSwitcher.
 */
export function PresetToggle({
  label = 'Toggle preset',
  className,
}: PresetToggleProps) {
  const { preset, setPreset } = usePreset();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  const isNeo = preset === 'neobrutalism';

  return (
    <button
      type="button"
      onClick={() => setPreset(isNeo ? 'default' : 'neobrutalism')}
      aria-label={label}
      title={
        isNeo ? 'Switch to Default preset' : 'Switch to Neobrutalism preset'
      }
      className={cn(
        'inline-flex h-7 w-7 items-center justify-center rounded-full transition-colors',
        'border-border border-(length:--just-border-width)',
        'text-muted hover:text-foreground',
        className
      )}
    >
      <span className="font-mono text-[10px] font-bold">
        {isNeo ? 'N' : 'D'}
      </span>
    </button>
  );
}

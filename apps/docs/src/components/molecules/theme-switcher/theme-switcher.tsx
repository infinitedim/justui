'use client';

import { useEffect, useState } from 'react';
import { useTheme } from 'next-themes';
import { SegmentedToggle } from '@/components/molecules/segmented-toggle';
import type { ThemeSwitcherProps } from './theme-switcher.types';

/**
 * Light/dark theme toggle molecule. Both modes are visible; the active one is
 * filled. Uses next-themes resolvedTheme for hydration-safe rendering.
 */
export function ThemeSwitcher({
  label = 'Toggle theme',
  className,
}: ThemeSwitcherProps) {
  const { resolvedTheme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  return (
    <SegmentedToggle
      label={label}
      className={className}
      value={resolvedTheme === 'dark' ? 'dark' : 'light'}
      onChange={setTheme}
      options={[
        { value: 'light', label: 'light' },
        { value: 'dark', label: 'dark' },
      ]}
    />
  );
}

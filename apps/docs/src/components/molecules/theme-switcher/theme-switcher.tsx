'use client';

import { useEffect, useState } from 'react';
import { Moon, Sun } from 'lucide-react';
import { useTheme } from 'next-themes';
import { cn } from '@/lib/cn';
import type { ThemeSwitcherProps } from './theme-switcher.types';

/**
 * Dark/light theme toggle molecule.
 * Extracted from the old navbar ThemeSwitcher.
 * Uses next-themes resolvedTheme for hydration-safe rendering.
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
    <button
      type="button"
      onClick={() => setTheme(resolvedTheme === 'dark' ? 'light' : 'dark')}
      aria-label={label}
      className={cn(
        'inline-flex h-7 w-7 items-center justify-center rounded-full transition-colors',
        'border-border border-(length:--just-border-width)',
        'text-muted hover:text-foreground',
        className
      )}
    >
      {resolvedTheme === 'dark' ? (
        <Sun size={13} aria-hidden="true" />
      ) : (
        <Moon size={13} aria-hidden="true" />
      )}
    </button>
  );
}

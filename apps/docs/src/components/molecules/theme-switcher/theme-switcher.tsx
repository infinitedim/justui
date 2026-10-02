'use client';

import { useEffect, useState } from 'react';
import { useTheme } from 'next-themes';
import { Moon, Sun } from 'lucide-react';
import { cn } from '@/lib/cn';
import type { ThemeSwitcherProps } from './theme-switcher.types';

/**
 * Light/dark theme toggle switch molecule.
 * Displays an interactive switch track with sliding thumb and mode icons.
 * Triggers smooth view transition or CSS cross-fade without harsh jumps.
 */
export function ThemeSwitcher({
  label = 'Toggle theme',
  className,
}: ThemeSwitcherProps) {
  const { resolvedTheme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  const isDark = resolvedTheme === 'dark';

  const handleToggle = () => {
    const nextTheme = isDark ? 'light' : 'dark';
    if (
      typeof document !== 'undefined' &&
      'startViewTransition' in document &&
      window.matchMedia('(prefers-reduced-motion: no-preference)').matches
    ) {
      document.startViewTransition(() => {
        setTheme(nextTheme);
      });
    } else {
      setTheme(nextTheme);
    }
  };

  return (
    <button
      type="button"
      role="switch"
      aria-checked={isDark}
      aria-label={label}
      onClick={handleToggle}
      className={cn(
        'just-press bg-card text-muted hover:text-foreground relative inline-flex h-7 w-13 items-center justify-between px-1.5',
        'rounded-(--just-radius-md) border-(length:--just-border-width) border-border shadow-xs',
        'cursor-pointer select-none transition-colors focus-visible:outline-hidden',
        className
      )}
    >
      <Sun
        size={12}
        className={cn(
          'transition-opacity duration-200 shrink-0 ml-0.5',
          isDark ? 'opacity-40' : 'opacity-0'
        )}
        aria-hidden="true"
      />
      <Moon
        size={12}
        className={cn(
          'transition-opacity duration-200 shrink-0 mr-0.5',
          isDark ? 'opacity-0' : 'opacity-40'
        )}
        aria-hidden="true"
      />
      <span
        className={cn(
          'bg-accent text-accent-foreground absolute top-1/2 -translate-y-1/2 left-1 h-5 w-5',
          'rounded-(--just-radius-sm) shadow-xs transition-transform duration-200 ease-in-out',
          'flex items-center justify-center pointer-events-none',
          isDark ? 'translate-x-6' : 'translate-x-0'
        )}
      >
        {isDark ? (
          <Moon size={11} className="stroke-[2.5]" aria-hidden="true" />
        ) : (
          <Sun size={11} className="stroke-[2.5]" aria-hidden="true" />
        )}
      </span>
    </button>
  );
}

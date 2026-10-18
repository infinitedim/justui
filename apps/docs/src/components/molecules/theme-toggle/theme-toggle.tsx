'use client';

// Client leaf: reads and switches the next-themes mode.
import { Moon, Sun } from 'lucide-react';
import { cn } from '@/lib/cn';
import { useThemeSwitch } from '@/lib/use-theme-switch';
import type { ThemeToggleProps } from './theme-toggle.types';

/** Moon in light mode, sun in dark mode. The switch runs the page curl. */
export function ThemeToggle({
  toDarkLabel,
  toLightLabel,
  className,
}: ThemeToggleProps) {
  const { isDark, toggle } = useThemeSwitch();
  const Icon = isDark ? Sun : Moon;
  return (
    <button
      type="button"
      aria-label={isDark ? toLightLabel : toDarkLabel}
      onClick={toggle}
      className={cn(
        'text-ip-text-secondary hover:bg-ip-hover hover:text-ip-text-primary flex size-9 cursor-pointer items-center justify-center rounded-[8px]',
        className
      )}
    >
      <Icon size={18} aria-hidden="true" />
    </button>
  );
}

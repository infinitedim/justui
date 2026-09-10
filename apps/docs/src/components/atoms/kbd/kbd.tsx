import { cn } from '@/lib/cn';
import type { KbdProps } from './kbd.types';

/**
 * Keyboard shortcut indicator atom. Server Component.
 * Renders an inline <kbd> element styled with JustUI design tokens.
 */
export function Kbd({ className, children, ...rest }: KbdProps) {
  return (
    <kbd
      className={cn(
        'border-border inline-flex items-center rounded border-(length:--just-border-width)',
        'bg-card text-muted px-1.5 py-0.5 font-mono text-[10px]',
        'shadow-solid',
        className
      )}
      {...rest}
    >
      {children}
    </kbd>
  );
}

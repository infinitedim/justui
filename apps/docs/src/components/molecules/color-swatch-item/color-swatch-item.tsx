'use client';

import { cn } from '@/lib/cn';
import type { ColorSwatchItemProps } from './color-swatch-item.types';

/**
 * Color swatch item molecule for the theme playground/studio.
 * Shows a colored circle with token name and value label.
 */
export function ColorSwatchItem({
  color,
  label,
  value,
  active = false,
  onClick,
  className,
}: ColorSwatchItemProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        'flex items-center gap-3 rounded-(--just-radius-md) px-3 py-2 text-left transition-colors',
        'border-(length:--just-border-width)',
        active
          ? 'border-accent bg-accent-muted shadow-solid'
          : 'border-border hover:bg-card',
        className
      )}
    >
      <span
        className="border-border h-6 w-6 shrink-0 rounded-full border-(length:--just-border-width)"
        style={{ backgroundColor: color }}
        aria-hidden="true"
      />
      <span className="flex flex-col">
        <span className="text-foreground font-mono text-xs">{label}</span>
        <span className="text-muted font-mono text-[10px]">{value}</span>
      </span>
    </button>
  );
}

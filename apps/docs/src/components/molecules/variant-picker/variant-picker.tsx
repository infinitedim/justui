'use client';

import { cn } from '@/lib/cn';
import type { VariantPickerProps } from './variant-picker.types';

/**
 * Variant picker molecule for selecting component variants in the catalog.
 * Uses ARIA radiogroup semantics for a11y.
 */
export function VariantPicker({
  options,
  value,
  onChange,
  label = 'Select variant',
  className,
}: VariantPickerProps) {
  return (
    <div
      role="radiogroup"
      aria-label={label}
      className={cn('flex flex-wrap gap-1.5', className)}
    >
      {options.map((opt) => (
        <button
          key={opt.value}
          type="button"
          role="radio"
          aria-checked={value === opt.value}
          onClick={() => onChange(opt.value)}
          className={cn(
            'rounded-(--just-radius-md) px-2.5 py-1 font-mono text-[11px] transition-colors',
            'border-(length:--just-border-width)',
            'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-2',
            value === opt.value
              ? 'border-accent bg-accent-muted text-accent-deep'
              : 'border-border text-muted hover:text-foreground'
          )}
        >
          {opt.label}
        </button>
      ))}
    </div>
  );
}

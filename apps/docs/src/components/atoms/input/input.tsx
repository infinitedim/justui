'use client';

import { forwardRef } from 'react';
import { cn } from '@/lib/cn';
import type { InputProps, InputSize } from './input.types';

const sizeClassMap: Record<InputSize, string> = {
  sm: 'h-8 px-3 text-xs',
  md: 'h-9 px-3 text-sm',
  lg: 'h-11 px-4 text-base',
};

/**
 * Text input atom with preset-aware borders.
 * Forwards ref for integration with form libraries and focus management.
 */
export const Input = forwardRef<HTMLInputElement, InputProps>(function Input(
  { inputSize = 'md', error = false, className, ...rest },
  ref
) {
  return (
    <input
      ref={ref}
      className={cn(
        'bg-card text-foreground w-full rounded-(--just-radius-md) font-mono transition-colors',
        'border-(length:--just-border-width)',
        'placeholder:text-muted',
        'focus:ring-accent/40 focus:ring-2 focus:outline-none',
        'disabled:pointer-events-none disabled:opacity-50',
        error ? 'border-error' : 'border-border',
        sizeClassMap[inputSize],
        className
      )}
      {...rest}
    />
  );
});

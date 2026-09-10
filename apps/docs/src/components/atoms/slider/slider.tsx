'use client';

import { forwardRef } from 'react';
import { cn } from '@/lib/cn';
import type { SliderProps } from './slider.types';

/**
 * Range slider atom built on native <input type="range">.
 * Client Component for onChange handling.
 * Custom styled via CSS using accent-color to match --just-accent.
 */
export const Slider = forwardRef<HTMLInputElement, SliderProps>(function Slider(
  { value, min = 0, max = 100, step = 1, label, className, ...rest },
  ref
) {
  return (
    <input
      ref={ref}
      type="range"
      value={value}
      min={min}
      max={max}
      step={step}
      aria-label={label}
      className={cn(
        'bg-border accent-accent h-2 w-full cursor-pointer appearance-none rounded-full',
        'focus-visible:outline-accent focus-visible:outline-2 focus-visible:outline-offset-4',
        'disabled:pointer-events-none disabled:opacity-50',
        className
      )}
      {...rest}
    />
  );
});

import { cn } from '@/lib/cn';
import type { DotGridProps } from './dot-grid.types';

/**
 * Decorative dot grid pattern atom. Server Component.
 * Renders via CSS radial-gradient for zero DOM elements per dot.
 */
export function DotGrid({
  cols = 5,
  rows = 5,
  gap = 16,
  dotSize = 1.5,
  className,
  style,
  ...rest
}: DotGridProps) {
  const w = (cols - 1) * gap + dotSize * 2;
  const h = (rows - 1) * gap + dotSize * 2;

  return (
    <div
      aria-hidden="true"
      className={cn('pointer-events-none select-none', className)}
      style={{
        width: w,
        height: h,
        backgroundImage: `radial-gradient(circle, var(--just-border) ${dotSize}px, transparent ${dotSize}px)`,
        backgroundSize: `${gap}px ${gap}px`,
        backgroundPosition: `${dotSize}px ${dotSize}px`,
        ...style,
      }}
      {...rest}
    />
  );
}

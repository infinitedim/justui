import { cn } from '@/lib/cn';
import type { FormulaMathBlockProps } from './formula-math-block.types';

/**
 * Formula / math block molecule. Server Component.
 * Renders a formatted mathematical expression with optional caption.
 * Uses monospace font for formula display without requiring a math rendering library.
 */
export function FormulaMathBlock({
  formula,
  caption,
  className,
  ...rest
}: FormulaMathBlockProps) {
  return (
    <figure
      className={cn(
        'flex flex-col items-center gap-2 rounded-(--just-radius-md) p-4',
        'border-border bg-card border-(length:--just-border-width)',
        className
      )}
      {...rest}
    >
      <code className="text-accent-deep font-mono text-sm">{formula}</code>
      {caption ? (
        <figcaption className="text-muted text-center font-mono text-[10px]">
          {caption}
        </figcaption>
      ) : null}
    </figure>
  );
}

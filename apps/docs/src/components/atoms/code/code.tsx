import { cn } from '@/lib/cn';
import type { CodeProps } from './code.types';

/**
 * Inline or block code atom. Server Component.
 * When `block` is true, wraps content in <pre><code>.
 */
export function Code({
  block = false,
  className,
  children,
  ...rest
}: CodeProps) {
  if (block) {
    return (
      <pre
        className={cn(
          'border-border overflow-x-auto rounded-(--just-radius-md) border',
          'bg-card shadow-solid p-4',
          className
        )}
      >
        <code className="text-foreground font-mono text-sm" {...rest}>
          {children}
        </code>
      </pre>
    );
  }

  return (
    <code
      className={cn(
        'bg-card text-accent-deep rounded px-1.5 py-0.5 font-mono text-[13px]',
        'border-border border-(length:--just-border-width)',
        className
      )}
      {...rest}
    >
      {children}
    </code>
  );
}

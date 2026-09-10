import { cn } from '@/lib/cn';
import type { CodeBlockHeaderProps } from './code-block-header.types';

/**
 * Code block header bar molecule. Server Component.
 * Shows file name / language label with optional action slot (copy button, etc.).
 */
export function CodeBlockHeader({
  title,
  actions,
  className,
}: CodeBlockHeaderProps) {
  return (
    <div
      className={cn(
        'flex items-center justify-between rounded-t-(--just-radius-md) px-4 py-2',
        'border-border bg-card border-(length:--just-border-width) border-b-0',
        className
      )}
    >
      <span className="text-muted font-mono text-xs">{title}</span>
      {actions ? (
        <div className="flex items-center gap-1">{actions}</div>
      ) : null}
    </div>
  );
}

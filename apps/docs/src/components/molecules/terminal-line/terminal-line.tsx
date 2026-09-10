import { cn } from '@/lib/cn';
import type {
  TerminalLineProps,
  TerminalLineKind,
} from './terminal-line.types';

const kindClassMap: Record<TerminalLineKind, string> = {
  output: 'text-secondary',
  info: 'text-info',
  success: 'text-success',
  error: 'text-error',
  warning: 'text-warning',
};

/**
 * Single output line in the interactive terminal simulator. Server Component.
 * Color-coded by kind using JustUI semantic color tokens.
 */
export function TerminalLine({
  kind = 'output',
  timestamp,
  className,
  children,
  ...rest
}: TerminalLineProps) {
  return (
    <div
      className={cn(
        'flex gap-2 font-mono text-xs leading-6',
        kindClassMap[kind],
        className
      )}
      {...rest}
    >
      {timestamp ? (
        <span className="text-muted shrink-0 select-none">{timestamp}</span>
      ) : null}
      <span className="whitespace-pre-wrap">{children}</span>
    </div>
  );
}

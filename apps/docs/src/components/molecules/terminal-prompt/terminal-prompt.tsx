import { cn } from '@/lib/cn';
import type { TerminalPromptProps } from './terminal-prompt.types';

/**
 * Terminal prompt line molecule for the interactive CLI simulator.
 * Shows a prefix, command text, and optional static block cursor.
 * Server Component.
 */
export function TerminalPrompt({
  prefix = '$',
  command,
  cursor = false,
  className,
  ...rest
}: TerminalPromptProps) {
  return (
    <div
      className={cn('flex gap-2 font-mono text-xs leading-6', className)}
      {...rest}
    >
      <span className="text-accent-text shrink-0 select-none">{prefix}</span>
      <span className="text-foreground">{command}</span>
      {cursor ? (
        <span
          data-testid="terminal-cursor"
          className="bg-accent inline-block h-4 w-1.5 self-center"
          aria-hidden="true"
        />
      ) : null}
    </div>
  );
}

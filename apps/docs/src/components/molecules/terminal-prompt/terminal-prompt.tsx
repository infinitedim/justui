import { cn } from '@/lib/cn';
import type { TerminalPromptProps } from './terminal-prompt.types';

/**
 * A command line already run in the interactive CLI simulator.
 * The live, editable prompt is an <input> owned by InteractiveTerminal.
 * Server Component.
 */
export function TerminalPrompt({
  prefix = '$',
  command,
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
    </div>
  );
}

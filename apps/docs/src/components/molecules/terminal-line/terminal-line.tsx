import { cn } from '@/lib/cn';
import type {
  TerminalLineProps,
  TerminalLineKind,
} from './terminal-line.types';

const glyphClassMap: Record<TerminalLineKind, string> = {
  output: 'text-muted',
  info: 'text-info',
  success: 'text-success',
  error: 'text-error',
  warning: 'text-warning',
};

/** CLI status glyphs (logger.rs) and the color the CLI prints them in. */
const GLYPH_KIND: Record<string, TerminalLineKind> = {
  '\u2139': 'info',
  '\u2713': 'success',
  '\u2714': 'success',
  '\u25cf': 'success',
  '\u26a0': 'warning',
  '\u2717': 'error',
};

/**
 * Single output line in the interactive terminal simulator. Server Component.
 *
 * Only the leading status glyph (or box-drawing character) takes the
 * semantic color; the words stay in foreground tokens so small mono text
 * keeps AA contrast in both themes.
 */
export function TerminalLine({
  kind = 'output',
  timestamp,
  className,
  children,
  ...rest
}: TerminalLineProps) {
  const text = typeof children === 'string' ? children : null;
  const match = text ? /^(\s*)([\u0080-\uffff])(.*)$/s.exec(text) : null;
  const glyphKind = match ? (GLYPH_KIND[match[2]] ?? kind) : kind;

  return (
    <div
      className={cn(
        'flex gap-2 font-mono text-xs leading-6',
        kind === 'output' ? 'text-secondary' : 'text-foreground',
        className
      )}
      {...rest}
    >
      {timestamp ? (
        <span className="text-muted shrink-0 select-none">{timestamp}</span>
      ) : null}
      <span className="whitespace-pre-wrap">
        {match ? (
          <>
            {match[1]}
            <span className={glyphClassMap[glyphKind]}>{match[2]}</span>
            {match[3]}
          </>
        ) : (
          children
        )}
      </span>
    </div>
  );
}

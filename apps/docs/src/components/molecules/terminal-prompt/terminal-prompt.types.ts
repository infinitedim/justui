import type { HTMLAttributes } from 'react';

export interface TerminalPromptProps extends HTMLAttributes<HTMLDivElement> {
  /** Prompt prefix string (e.g. "$" or "justui>"). */
  prefix?: string;
  /** The command text to display. */
  command: string;
  /** Whether to show a blinking cursor. */
  cursor?: boolean;
}

import type { TerminalLineKind } from '@/components/molecules/terminal-line';

export interface InteractiveTerminalHandle {
  runCommand: (command: string) => void;
}

export interface InteractiveTerminalProps {
  /** Language for i18n labels. */
  lang?: string;
  /** Called with the public components a command copied into the project. */
  onMount?: (components: string[]) => void;
  /** Called when a command changes the preset. */
  onPresetChange?: (preset: 'default' | 'neobrutalism') => void;
  className?: string;
}

export interface TerminalBufferEntry {
  id: string;
  kind: 'prompt' | 'output';
  promptPrefix?: string;
  text: string;
  lineKind?: TerminalLineKind;
}

import type { TerminalLineKind } from '@/components/molecules/terminal-line';

export interface InteractiveTerminalProps {
  /** Language for i18n labels on action chips. */
  lang?: string;
  /** Called when a command produces a mount event. */
  onMount?: (components: string[]) => void;
  /** Called when a command changes the preset. */
  onPresetChange?: (preset: 'default' | 'neobrutalism') => void;
  /** Called when the stage should be cleared. */
  onClear?: () => void;
  className?: string;
}

export interface TerminalBufferEntry {
  id: string;
  kind: 'prompt' | 'output';
  promptPrefix?: string;
  text: string;
  lineKind?: TerminalLineKind;
}

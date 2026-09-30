export type StageView = 'preview' | 'code';

export interface MountedWidget {
  id: string;
  component: string;
  mountedAt: number;
}

export interface LivingStageProps {
  /** Currently mounted widgets. */
  widgets: MountedWidget[];
  /** Current active preset. */
  preset?: 'default' | 'neobrutalism';
  lang?: string;
  className?: string;
  /** Called when the Clear button in the toolbar is clicked. */
  onClear?: () => void;
  /** Called when a command CTA (like in empty state) is clicked. */
  onRunCommand?: (command: string) => void;
}

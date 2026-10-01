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
}

import type { ReactNode, RefObject } from 'react';
import type { Locale } from '@/lib/i18n';
import type { KitDictionary } from '@/lib/kit-translations';
import type { LandingDictionary } from '@/lib/landing-translations';

export interface CutSequenceProps {
  lang: Locale;
}

/**
 * How the sequence plays. `rest` is the prerendered finished layout,
 * `pinned` scrubs a 280vh sticky stage, `flow` scrubs in place where the
 * stage does not fit the viewport, `stepped` is reduced motion with a
 * before/after switch.
 */
export type CutMode = 'rest' | 'pinned' | 'flow' | 'stepped';

export interface CutHeaderProps {
  id: string;
  title: string;
  lead: string;
  command: string;
  tail: string;
  /** The before/after switch, shown only in the `stepped` mode. */
  control: ReactNode;
}

export interface CutRunnerProps {
  kit: KitDictionary;
  /** Dashed tag left in the empty slot. */
  cutEmpty: string;
  partsCount: string;
}

export interface FileTreeProps {
  /** Part folder relative to `lib/`, e.g. `widgets/button/`. */
  folder: string;
  /** Shared folder relative to `lib/`. */
  shared: string;
  /** Files in the part folder, main widget first. */
  files: readonly string[];
  sharedMore: string;
  verify: string;
}

export interface CutMoverProps {
  label: string;
  file: string;
}

export interface CutStageProps {
  /** The positioned box the flight is measured in. */
  stageRef: RefObject<HTMLDivElement | null>;
  /** The part being cut. */
  part: string;
  /** Its files, main widget first. */
  files: readonly string[];
  /** How many shared files come with it. */
  shared: number;
  t: LandingDictionary;
  kit: KitDictionary;
}

import type { ReactNode } from 'react';
import type { JustUIPreset } from '@/lib/presets';

export interface PresetStageProps {
  /** Fixed preset; omit to follow the visitor's choice. */
  preset?: JustUIPreset;
  /** Join the cross-dissolve when the visitor changes preset. */
  animated?: boolean;
  className?: string;
  children: ReactNode;
}

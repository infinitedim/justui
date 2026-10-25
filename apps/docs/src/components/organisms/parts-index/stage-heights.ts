/**
 * Minimum height of each part's stage on the components page: the room a
 * live Flutter view needs, plus the stage's 8px top padding. A live view
 * fills the box its React fallback sets and cannot grow past it, so these
 * keep every scene whole (an open accordion, an input with its error).
 * `apps/showcase/test/scenes/stage_heights_test.dart` measures each scene
 * at rest and after the growth a visitor can trigger (an input error, an
 * open accordion) with the EN and ID copy, and fails when one outgrows
 * its stage.
 */
export const DEFAULT_STAGE = 'min-h-[64px]';

/** Stages taller than [DEFAULT_STAGE], by part slug. */
export const STAGE_HEIGHTS: Readonly<Record<string, string>> = {
  accordion: 'min-h-[128px]',
  card: 'min-h-[112px]',
  carousel: 'min-h-[128px]',
  'date-picker': 'min-h-[336px]',
  'date-range-picker': 'min-h-[336px]',
  input: 'min-h-[120px]',
  radio: 'min-h-[120px]',
  'radio-group': 'min-h-[120px]',
  table: 'min-h-[136px]',
};

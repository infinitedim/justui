/**
 * The six runners of the components page (landing v3 "Parts index"), in
 * page order. Hand-typed because the registry has no group field;
 * `test/part-groups.test.ts` checks they hold every part exactly once.
 */
export const PART_GROUPS = [
  { id: 'actions', letter: 'A', slugs: ['button', 'icon-button', 'toggle'] },
  {
    id: 'inputs',
    letter: 'B',
    slugs: [
      'input',
      'checkbox',
      'radio',
      'radio-group',
      'switch',
      'slider',
      'select',
      'date-picker',
      'date-range-picker',
      'time-picker',
    ],
  },
  {
    id: 'navigation',
    letter: 'C',
    slugs: ['tabs', 'breadcrumb', 'bottom-nav', 'sidebar'],
  },
  {
    id: 'overlays',
    letter: 'D',
    slugs: ['dialog', 'sheet', 'tooltip', 'toast'],
  },
  {
    id: 'display',
    letter: 'E',
    slugs: [
      'avatar',
      'avatar-group',
      'badge',
      'card',
      'carousel',
      'progress',
      'skeleton',
      'table',
      'accordion',
    ],
  },
  {
    id: 'layout',
    letter: 'F',
    slugs: ['separator', 'scroll-area', 'resizable'],
  },
] as const;

/** One runner of the components page. */
export type PartGroup = (typeof PART_GROUPS)[number];

/** Id of a runner, the key of its name in the page copy. */
export type PartGroupId = PartGroup['id'];

/**
 * Parts whose demo needs a wide cell: v3 `ixCellW`, plus breadcrumb, whose
 * live trail is wider than a narrow cell.
 */
const WIDE_PARTS: ReadonlySet<string> = new Set([
  'breadcrumb',
  'date-picker',
  'date-range-picker',
  'bottom-nav',
  'sidebar',
  'dialog',
  'sheet',
  'carousel',
  'table',
  'accordion',
  'scroll-area',
  'resizable',
]);

/** True when [slug]'s demo takes a wide cell on the components page. */
export function isWidePart(slug: string): boolean {
  return WIDE_PARTS.has(slug);
}

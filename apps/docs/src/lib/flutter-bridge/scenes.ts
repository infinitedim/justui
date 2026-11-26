/**
 * Parts that have a live Flutter scene in `apps/showcase/lib/scenes`.
 * `test/flutter-scenes.test.ts` keeps this list equal to the Dart registry;
 * every other part stays React.
 */
export const FLUTTER_SCENES = [
  'accordion',
  'avatar',
  'avatar-group',
  'badge',
  'bottom-nav',
  'breadcrumb',
  'button',
  'card',
  'carousel',
  'checkbox',
  'date-picker',
  'date-range-picker',
  'dialog',
  'icon-button',
  'input',
  'progress',
  'radio',
  'radio-group',
  'resizable',
  'scroll-area',
  'select',
  'separator',
  'sheet',
  'sidebar',
  'skeleton',
  'slider',
  'switch',
  'table',
  'tabs',
  'time-picker',
  'toast',
  'toggle',
  'tooltip',
] as const;

export type FlutterScene = (typeof FLUTTER_SCENES)[number];

/** True when [slug] has a live Flutter scene. */
export function isFlutterScene(slug: string): slug is FlutterScene {
  return FLUTTER_SCENES.some((scene) => scene === slug);
}

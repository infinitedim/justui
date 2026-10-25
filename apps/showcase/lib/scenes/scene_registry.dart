import 'actions/actions_scenes.dart';
import 'display/display_scenes.dart';
import 'inputs/inputs_scenes.dart';
import 'layout/layout_scenes.dart';
import 'navigation/navigation_scenes.dart';
import 'overlays/overlays_scenes.dart';
import 'scene.dart';

/// Every live scene, keyed by registry slug (`registry/index.json`).
///
/// Each v3 group owns one map, so parallel work never edits the same file.
final Map<String, SceneBuilder> sceneRegistry = <String, SceneBuilder>{
  ...actionsScenes,
  ...inputsScenes,
  ...navigationScenes,
  ...overlaysScenes,
  ...displayScenes,
  ...layoutScenes,
};

/// Parts that stay React on the docs pages because they need a core change
/// first. Together with [sceneRegistry] they cover all 33 public parts
/// (`test/scenes/scene_registry_test.dart`).
const Set<String> reactOnlyScenes = <String>{
  // Its menu opens below the field, and a view has a fixed size: the
  // options would be clipped (the React fallback is a native select).
  'select',
  // Core paints these surfaces only in private widgets inside an overlay
  // entry or portal, so they cannot render inline in a view yet.
  'dialog',
  'sheet',
  'toast',
  'tooltip',
  // Neobrutalism draws an ink shadow under the selected ink fill (Ink and
  // Paper Rule A: no shadow there), and the styles have no hook to drop it.
  'checkbox',
  'toggle',
  // Off-center spinner values are drawn at 40% opacity (2.1:1 contrast) in
  // a shadowed card inside the picker card.
  'time-picker',
  // No visible focus on their items (WCAG 2.4.7); tabs also add an
  // unlabelled stop. Neobrutalism borders stay grey or rounded.
  'bottom-nav',
  'sidebar',
  'tabs',
  // Core shows its bar only while content overflows, and then the area is
  // a Tab stop with no visible focus.
  'scroll-area',
};

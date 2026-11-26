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

/// Parts that stay React on the docs pages. Empty: all 33 public parts now
/// have live Flutter scenes in [sceneRegistry]
/// (`test/scenes/scene_registry_test.dart`).
const Set<String> reactOnlyScenes = <String>{};

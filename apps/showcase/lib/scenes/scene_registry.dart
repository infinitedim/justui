import 'actions/actions_scenes.dart';
import 'scene.dart';

/// Every live scene, keyed by registry slug (`registry/index.json`).
///
/// Each v3 group owns one map, so parallel work never edits the same file.
final Map<String, SceneBuilder> sceneRegistry = <String, SceneBuilder>{
  ...actionsScenes,
};

/// Parts that stay React on the docs pages for now (they need a core change
/// or are not ported yet). Together with [sceneRegistry] they must cover all
/// 33 public parts once every group lands; `test/scenes/scene_registry_test.dart`
/// checks the slugs.
const Set<String> reactOnlyScenes = <String>{};

import '../scene.dart';
import 'button_scene.dart';
import 'icon_button_scene.dart';

/// Scenes of the v3 "Actions" group.
const Map<String, SceneBuilder> actionsScenes = <String, SceneBuilder>{
  'button': buttonScene,
  'icon-button': iconButtonScene,
};

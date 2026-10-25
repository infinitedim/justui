import '../scene.dart';
import 'resizable_scene.dart';
import 'separator_scene.dart';

/// Scenes of the v3 "Layout" group.
const Map<String, SceneBuilder> layoutScenes = <String, SceneBuilder>{
  'separator': separatorScene,
  'resizable': resizableScene,
};

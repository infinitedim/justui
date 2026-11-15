import '../scene.dart';
import 'dialog_scene.dart';
import 'sheet_scene.dart';
import 'toast_scene.dart';
import 'tooltip_scene.dart';

/// Scenes of the v3 "Overlays" group.
const Map<String, SceneBuilder> overlaysScenes = <String, SceneBuilder>{
  'dialog': dialogScene,
  'sheet': sheetScene,
  'toast': toastScene,
  'tooltip': tooltipScene,
};

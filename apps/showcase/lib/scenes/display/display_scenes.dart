import '../scene.dart';
import 'avatar_group_scene.dart';
import 'avatar_scene.dart';
import 'badge_scene.dart';
import 'card_scene.dart';
import 'progress_scene.dart';
import 'skeleton_scene.dart';
import 'table_scene.dart';

/// Scenes of the v3 "Display" group.
const Map<String, SceneBuilder> displayScenes = <String, SceneBuilder>{
  'avatar': avatarScene,
  'avatar-group': avatarGroupScene,
  'badge': badgeScene,
  'card': cardScene,
  'progress': progressScene,
  'skeleton': skeletonScene,
  'table': tableScene,
};

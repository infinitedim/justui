import '../scene.dart';
import 'bottom_nav_scene.dart';
import 'breadcrumb_scene.dart';
import 'sidebar_scene.dart';
import 'tabs_scene.dart';

/// Scenes of the v3 "Navigation" group.
const Map<String, SceneBuilder> navigationScenes = <String, SceneBuilder>{
  'breadcrumb': breadcrumbScene,
  'bottom-nav': bottomNavScene,
  'sidebar': sidebarScene,
  'tabs': tabsScene,
};

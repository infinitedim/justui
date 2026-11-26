// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../scene.dart';

/// Part bottom-nav: three-destination fixed bar (`Home`, `Search`, `Profile`),
/// like `KitPart` `bottom-nav` (`KitBottomNav`, `max-w-62.5`).
Widget bottomNavScene(BuildContext context, SceneContext scene) =>
    _BottomNavDemo(scene: scene);

class const _BottomNavDemo({required final SceneContext scene})
    extends StatefulWidget {
  @override
  State<_BottomNavDemo> createState() => _BottomNavDemoState();
}

class _BottomNavDemoState extends State<_BottomNavDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = widget.scene.strings.list('bottomNav');
    final String home = labels.isNotEmpty ? labels[0] : 'Home';
    final String search = labels.length > 1 ? labels[1] : 'Search';
    final String profile = labels.length > 2 ? labels[2] : 'Profile';

    return SizedBox(
      width: 250,
      child: JustBottomNav(
        variant: .fixed,
        selectedIndex: _selectedIndex,
        onItemSelected: (int index) => setState(() => _selectedIndex = index),
        semanticsLabel: widget.scene.strings.text('bottomNavLabel'),
        showLabels: true,
        items: <JustBottomNavItem>[
          JustBottomNavItem(
            label: home,
            icon: const Icon(Icons.home_outlined, size: 18),
            activeIcon: const Icon(Icons.home, size: 18),
          ),
          JustBottomNavItem(
            label: search,
            icon: const Icon(Icons.search, size: 18),
          ),
          JustBottomNavItem(
            label: profile,
            icon: const Icon(Icons.person_outline, size: 18),
            activeIcon: const Icon(Icons.person, size: 18),
          ),
        ],
      ),
    );
  }
}

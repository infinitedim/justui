// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import '../scene.dart';

/// Part sidebar: compact 180 px vertical section panel with `Components`
/// active by default, like `KitPart` `sidebar` (`KitSidebar`, `w-45`).
Widget sidebarScene(BuildContext context, SceneContext scene) =>
    _SidebarDemo(scene: scene);

class const _SidebarDemo({required final SceneContext scene})
    extends StatefulWidget {
  @override
  State<_SidebarDemo> createState() => _SidebarDemoState();
}

class _SidebarDemoState extends State<_SidebarDemo> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = widget.scene.strings.list('sidebar');
    final String overview = labels.isNotEmpty ? labels[0] : 'Overview';
    final String components = labels.length > 1 ? labels[1] : 'Components';
    final String settings = labels.length > 2 ? labels[2] : 'Settings';

    // JustSidebar stretches to maxHeight when height constraints are bounded,
    // so UnconstrainedBox keeps it sized to its 3 items.
    return UnconstrainedBox(
      alignment: .topLeft,
      child: JustSidebar(
        variant: .inset,
        width: 180,
        autoCollapse: false,
        selectedIndex: _selectedIndex,
        onItemSelected: (int index) => setState(() => _selectedIndex = index),
        semanticsLabel: widget.scene.strings.text('sidebarLabel'),
        items: <JustSidebarItem>[
          JustSidebarItem(
            label: overview,
            icon: const Icon(Icons.dashboard_outlined, size: 16),
          ),
          JustSidebarItem(
            label: components,
            icon: const Icon(Icons.widgets_outlined, size: 16),
          ),
          JustSidebarItem(
            label: settings,
            icon: const Icon(Icons.settings_outlined, size: 16),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/sidebar/just_sidebar.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_variants.dart';

@widgetbook.UseCase(name: 'Default Sidebar', type: JustSidebar)
Widget buildJustSidebarDefaultUseCase(BuildContext context) {
  final variant = context.knobs.object.dropdown<JustSidebarVariant>(
    label: 'Variant',
    options: JustSidebarVariant.values,
    initialOption: JustSidebarVariant.default_,
  );

  return Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      height: .infinity,
      child: _InteractiveSidebarDemo(variant: variant),
    ),
  );
}

class _InteractiveSidebarDemo extends StatefulWidget {
  final JustSidebarVariant variant;

  const _InteractiveSidebarDemo({required this.variant});

  @override
  State<_InteractiveSidebarDemo> createState() =>
      _InteractiveSidebarDemoState();
}

class _InteractiveSidebarDemoState extends State<_InteractiveSidebarDemo> {
  bool _isCollapsed = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return JustSidebar(
      isCollapsed: _isCollapsed,
      variant: widget.variant,
      onCollapsedChanged: (bool collapsed) {
        setState(() {
          _isCollapsed = collapsed;
        });
      },
      selectedIndex: _selectedIndex,
      onItemSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          _isCollapsed ? 'UI' : 'JustUI Admin',
          style: const TextStyle(fontWeight: .bold, fontSize: 18.0),
        ),
      ),
      items: const [
        JustSidebarItem(
          label: 'Dashboard',
          icon: Icon(IconData(0xe1b0, fontFamily: 'MaterialIcons')),
        ),
        JustSidebarItem(
          label: 'Analytics',
          icon: Icon(IconData(0xe0b9, fontFamily: 'MaterialIcons')),
        ),
        JustSidebarItem(
          label: 'Settings',
          icon: Icon(IconData(0xe57f, fontFamily: 'MaterialIcons')),
        ),
      ],
    );
  }
}

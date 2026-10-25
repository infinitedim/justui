// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_style.dart';

import '../scene.dart';

/// Part 22, sidebar: a vertical section list in a bordered card, like
/// `KitPart` `sidebar` (`KitSidebar`, `w-45` = 180 px).
Widget sidebarScene(BuildContext context, SceneContext scene) {
  return Semantics(
    label: scene.strings.text('sidebarLabel'),
    container: true,
    explicitChildNodes: true,
    child: _Sidebar(items: scene.strings.list('sidebar')),
  );
}

/// Holds the current section; core's sidebar is controlled.
class const _Sidebar({required final List<String> items})
    extends StatefulWidget {
  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  // `KitSidebar` starts on its second item (`defaultIndex = 1`).
  int _current = 1;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    final JustSpacingScheme spacing = context.justSpacing;
    // Core collapses the sidebar to icons when the screen is narrower than
    // the md breakpoint. A docs view is only as wide as its stage, so the
    // scene reports a desktop-wide screen to show the expanded panel the
    // React demo shows.
    return MediaQuery(
      data: media.copyWith(size: Size(JustBreakpoints.lg, media.size.height)),
      child: SizedBox(
        width: 180,
        height: 176,
        child: JustSidebar(
          variant: .inset,
          width: 180,
          isCollapsible: false,
          selectedIndex: _current,
          onItemSelected: (int index) => setState(() => _current = index),
          // The items have no icon, but core still puts a `spacing.md` gap
          // after the icon slot; dropping the start padding by the same
          // amount keeps the label inset equal on both sides, as in React.
          style: JustSidebarStyle(
            itemPadding: .fromLTRB(0, spacing.sm, spacing.md, spacing.sm),
          ),
          items: <JustSidebarItem>[
            for (final String item in widget.items)
              JustSidebarItem(label: item, icon: const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

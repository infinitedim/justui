// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs.dart';

import '../scene.dart';

/// Part 23, tabs: three underlined section tabs with the first selected, like
/// `KitPart` `tabs` (`KitTabs`).
///
/// The React demo shows the tab list only, so every tab's page is empty and
/// the height fits the header row (core's tabs expand their pages to fill
/// it). `isScrollable` keeps the tabs at their content width, as in React.
Widget tabsScene(BuildContext context, SceneContext scene) {
  return Semantics(
    label: scene.strings.text('tabsLabel'),
    container: true,
    explicitChildNodes: true,
    child: SizedBox(
      height: _headerHeight,
      child: JustTabs.line(
        isScrollable: true,
        tabs: <JustTab>[
          for (final String tab in scene.strings.list('tabs'))
            JustTab(label: tab, content: const SizedBox.shrink()),
        ],
      ),
    ),
  );
}

/// Core's line tab row: a 26 px body line plus vertical `spacing.md` (12)
/// padding on each side.
const double _headerHeight = 50;

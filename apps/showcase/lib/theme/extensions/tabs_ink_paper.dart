// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs_style.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs_theme.dart';

import '../ink_paper_tokens.dart';

/// Tabs overrides for Ink and Paper.
///
/// Mirrors `KitTabs`: ink indicator bar (2 px default, 4 px neobrutalism),
/// primary active text, tertiary inactive text, and subtle vs ink bottom rule.
JustTabsTheme tabsInkPaper(JustThemePreset preset, InkPaperRoles r) {
  final bool neo = preset == .neobrutalism;
  return JustTabsTheme(
    lineStyle: JustTabsStyle(
      indicatorColor: r.inverse,
      indicatorThickness: neo ? 4.0 : 2.0,
      activeColor: r.textPrimary,
      inactiveColor: r.textTertiary,
      borderBottomColor: neo ? r.textPrimary : r.borderSubtle,
      borderBottomWidth: neo ? 2.5 : 1.0,
      tabPadding: const .symmetric(horizontal: 4.0, vertical: 10.0),
    ),
  );
}

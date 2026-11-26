// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_style.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_theme.dart';

import '../ink_paper_tokens.dart';

/// Sidebar overrides for Ink and Paper.
///
/// Mirrors `KitSidebar`: surface card panel, 10 px default vs sharp
/// neobrutalism radius, selection vs inverse fill for the current item, and
/// compact item padding and spacing.
JustSidebarTheme sidebarInkPaper(JustThemePreset preset, InkPaperRoles r) {
  final bool neo = preset == .neobrutalism;
  return JustSidebarTheme(
    insetStyle: JustSidebarStyle(
      backgroundColor: r.surface,
      borderColor: neo ? r.textPrimary : r.borderSubtle,
      borderRadius: neo ? .zero : const .all(.circular(10.0)),
      selectedBackgroundColor: neo ? r.inverse : r.selection,
      selectedForegroundColor: neo ? r.onInverse : r.textPrimary,
      activeColor: r.textPrimary,
      inactiveColor: r.textPrimary,
      itemBorderRadius: neo ? .zero : const .all(.circular(6.0)),
      padding: const .all(6.0),
      itemSpacing: 2.0,
      itemPadding: const .symmetric(horizontal: 10.0, vertical: 8.0),
    ),
  );
}

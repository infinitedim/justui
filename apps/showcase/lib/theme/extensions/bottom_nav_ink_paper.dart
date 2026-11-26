// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_style.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_theme.dart';

import '../ink_paper_tokens.dart';

/// Bottom navigation overrides for Ink and Paper.
///
/// Mirrors `KitBottomNav`: surface fill, subtle vs ink top border, primary
/// active and tertiary inactive items, and an ink active indicator bar.
JustBottomNavTheme bottomNavInkPaper(JustThemePreset preset, InkPaperRoles r) {
  final bool neo = preset == .neobrutalism;
  return JustBottomNavTheme(
    fixedStyle: JustBottomNavStyle(
      backgroundColor: r.surface,
      borderColor: neo ? r.textPrimary : r.borderSubtle,
      activeColor: r.textPrimary,
      inactiveColor: r.textTertiary,
      activeIndicatorColor: r.inverse,
      showActiveIndicator: true,
      iconSize: 18.0,
    ),
  );
}

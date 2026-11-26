import 'package:material_ui/material_ui.dart' show ThemeExtension;
import 'package:just_ui_core/just_ui_core.dart';

import '../ink_paper_tokens.dart';
import 'bottom_nav_ink_paper.dart';
import 'sidebar_ink_paper.dart';
import 'tabs_ink_paper.dart';

/// Ink and Paper theme overrides for the v3 "Navigation" group. Each entry replaces
/// the core default of the same type in `inkPaperExtensions`.
List<ThemeExtension<dynamic>> navigationOverrides(
  JustThemePreset preset,
  InkPaperRoles roles,
) => <ThemeExtension<dynamic>>[
  tabsInkPaper(preset, roles),
  bottomNavInkPaper(preset, roles),
  sidebarInkPaper(preset, roles),
];

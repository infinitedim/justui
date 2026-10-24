import 'package:flutter/material.dart' show ThemeExtension;
import 'package:just_ui_core/just_ui_core.dart';

import '../ink_paper_tokens.dart';
import 'button_ink_paper.dart';

/// Ink and Paper theme overrides for the v3 "Actions" group. Each entry
/// replaces the core default of the same type in `inkPaperExtensions`.
List<ThemeExtension<dynamic>> actionsOverrides(
  JustThemePreset preset,
  InkPaperRoles roles,
) => <ThemeExtension<dynamic>>[buttonInkPaper(preset, roles)];

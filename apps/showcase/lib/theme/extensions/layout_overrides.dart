import 'package:flutter/material.dart' show ThemeExtension;
import 'package:just_ui_core/just_ui_core.dart';

import '../ink_paper_tokens.dart';
import 'resizable_ink_paper.dart';
import 'separator_ink_paper.dart';

/// Ink and Paper theme overrides for the v3 "Layout" group. Each entry replaces
/// the core default of the same type in `inkPaperExtensions`.
List<ThemeExtension<dynamic>> layoutOverrides(
  JustThemePreset preset,
  InkPaperRoles roles,
) => <ThemeExtension<dynamic>>[
  separatorInkPaper(preset, roles),
  resizableInkPaper(preset, roles),
];

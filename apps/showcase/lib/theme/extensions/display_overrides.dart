import 'package:flutter/material.dart' show ThemeExtension;
import 'package:just_ui_core/just_ui_core.dart';

import '../ink_paper_tokens.dart';
import 'card_ink_paper.dart';
import 'progress_ink_paper.dart';
import 'skeleton_ink_paper.dart';
import 'table_ink_paper.dart';

/// Ink and Paper theme overrides for the v3 "Display" group. Each entry replaces
/// the core default of the same type in `inkPaperExtensions`.
List<ThemeExtension<dynamic>> displayOverrides(
  JustThemePreset preset,
  InkPaperRoles roles,
) => <ThemeExtension<dynamic>>[
  cardInkPaper(preset, roles),
  progressInkPaper(preset, roles),
  skeletonInkPaper(preset, roles),
  tableInkPaper(preset, roles),
];

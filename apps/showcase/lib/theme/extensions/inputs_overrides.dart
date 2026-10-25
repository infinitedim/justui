import 'package:flutter/material.dart' show ThemeExtension;
import 'package:just_ui_core/just_ui_core.dart';

import '../ink_paper_tokens.dart';
import 'checkbox_ink_paper.dart';
import 'slider_ink_paper.dart';
import 'switch_ink_paper.dart';

/// Ink and Paper theme overrides for the v3 "Inputs" group. Each entry replaces
/// the core default of the same type in `inkPaperExtensions`.
List<ThemeExtension<dynamic>> inputsOverrides(
  JustThemePreset preset,
  InkPaperRoles roles,
) => <ThemeExtension<dynamic>>[
  checkboxInkPaper(preset, roles),
  switchInkPaper(preset, roles),
  sliderInkPaper(preset, roles),
];

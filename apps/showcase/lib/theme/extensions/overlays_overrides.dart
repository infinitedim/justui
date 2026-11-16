import 'package:material_ui/material_ui.dart' show ThemeExtension;
import 'package:just_ui_core/just_ui_core.dart';

import '../ink_paper_tokens.dart';
import 'dialog_ink_paper.dart';
import 'sheet_ink_paper.dart';
import 'toast_ink_paper.dart';
import 'tooltip_ink_paper.dart';

/// Ink and Paper theme overrides for the v3 "Overlays" group. Each entry replaces
/// the core default of the same type in `inkPaperExtensions`.
List<ThemeExtension<dynamic>> overlaysOverrides(
  JustThemePreset preset,
  InkPaperRoles roles,
) => <ThemeExtension<dynamic>>[
  dialogInkPaper(preset, roles),
  sheetInkPaper(preset, roles),
  toastInkPaper(preset, roles),
  tooltipInkPaper(preset, roles),
];

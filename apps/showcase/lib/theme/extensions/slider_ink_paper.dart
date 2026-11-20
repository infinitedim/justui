// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/slider/just_slider_style.dart';
import 'package:just_ui_core/src/components/slider/just_slider_theme.dart';

import '../ink_paper_tokens.dart';

/// Slider overrides for Ink and Paper.
///
/// The default preset needs none. Neobrutalism in core fills the thumb with
/// the cognac `warning` role; the docs `.ip-range` thumb is canvas with an
/// ink border, so the thumb takes the canvas.
JustSliderTheme sliderInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset != .neobrutalism) return JustSliderTheme.defaults;
  return JustSliderTheme(style: JustSliderStyle(thumbColor: r.canvas));
}

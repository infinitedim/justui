// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/switch/just_switch_style.dart';
import 'package:just_ui_core/src/components/switch/just_switch_theme.dart';

import '../ink_paper_tokens.dart';

/// Switch overrides for Ink and Paper.
///
/// The default preset needs none: the on track is `borderFocus` (ink). In
/// neobrutalism core paints the on track with the green `success` role and
/// the off thumb with `textInverse`, the canvas color, which vanishes on the
/// canvas-filled off track. Rule A makes "on" an ink fill with an
/// on-inverse thumb; the off thumb takes ink so it stays visible.
JustSwitchTheme switchInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset != .neobrutalism) return JustSwitchTheme.defaults;
  return JustSwitchTheme(
    style: JustSwitchStyle(
      activeTrackColor: r.inverse,
      activeThumbColor: r.onInverse,
      inactiveThumbColor: r.textPrimary,
    ),
  );
}

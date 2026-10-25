// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart' show BorderRadius, Radius;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/skeleton/just_skeleton_style.dart';
import 'package:just_ui_core/src/components/skeleton/just_skeleton_theme.dart';

import '../ink_paper_tokens.dart';

/// Skeleton overrides for Ink and Paper.
///
/// Core paints slate placeholders (`#E2E8F0`, `#1E293B`) that are foreign to
/// the warm neutrals, and animates them. The docs demo is static, so the
/// duration is zero: core then paints the plain base color. Neobrutalism
/// skeletons pulse in core, and their static frame is the base color at 30%;
/// the control border at 30% lands next to the selection fill the default
/// preset shows, so both presets read the same.
JustSkeletonTheme skeletonInkPaper(JustThemePreset preset, InkPaperRoles r) {
  final bool neo = preset == .neobrutalism;
  return JustSkeletonTheme(
    style: JustSkeletonStyle(
      backgroundColor: neo ? r.borderControl : r.selection,
      shimmerColor: r.hover,
      duration: Duration.zero,
      fallbackRadius: neo
          ? BorderRadius.zero
          : const BorderRadius.all(Radius.circular(6)),
    ),
  );
}

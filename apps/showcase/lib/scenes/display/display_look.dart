import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import '../../theme/ink_paper_theme.dart';
import '../../theme/ink_paper_tokens.dart';

/// Ink and Paper values the Display scenes pass per instance.
///
/// Avatar and badge have no core `ThemeExtension`, so their Ink and Paper
/// look can only come in through a per-instance style; this reads the roles
/// of the active mode and preset from the view's theme.
class const DisplayLook({
  /// Roles of the active mode.
  required final InkPaperRoles roles,

  /// Whether the view shows the neobrutalism preset.
  required final bool neo,
}) {
  /// The look of the view [context] belongs to.
  factory DisplayLook.of(BuildContext context) {
    final JustThemeData theme = JustThemeProvider.of(context).theme;
    final InkPaperRoles dark = InkPaperTheme.roles(.dark);
    return DisplayLook(
      roles: theme.colors.background == dark.canvas
          ? dark
          : InkPaperTheme.roles(.light),
      neo: theme.preset == .neobrutalism,
    );
  }

  /// Hairline of containers: subtle in default, an ink line in neobrutalism.
  Color get containerBorder => neo ? roles.textPrimary : roles.borderSubtle;

  /// Width of a container outline (`--ip-line`).
  double get line => neo ? 2.5 : 1;

  /// Weight of short strong labels (`--ip-strong-weight`).
  FontWeight get strongWeight => neo ? .w700 : .w600;
}

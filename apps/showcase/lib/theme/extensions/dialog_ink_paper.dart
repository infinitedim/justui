// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog_style.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog_theme.dart';

import '../ink_paper_tokens.dart';

/// Dialog overrides for Ink and Paper.
///
/// Default: raised fill, 12 px card radius, `p-4` padding, and no border.
/// Neobrutalism: raised fill, 2.5 px ink border, zero radius, and hard ink
/// offset shadow from the theme.
JustDialogTheme dialogInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset == .neobrutalism) {
    final JustDialogStyle neoStyle = JustDialogStyle(
      backgroundColor: r.raised,
      borderColor: r.textPrimary,
      borderWidth: 2.5,
      borderRadius: .zero,
      padding: const .all(16),
    );
    return JustDialogTheme(
      centerStyle: neoStyle,
      bottomStyle: neoStyle,
      topStyle: neoStyle,
    );
  }
  return JustDialogTheme(
    centerStyle: JustDialogStyle(
      backgroundColor: r.raised,
      borderWidth: 0.0,
      borderRadius: const .all(.circular(12)),
      padding: const .all(16),
    ),
    bottomStyle: JustDialogStyle(
      backgroundColor: r.raised,
      borderWidth: 0.0,
      borderRadius: const .vertical(top: .circular(12)),
      padding: const .all(16),
    ),
    topStyle: JustDialogStyle(
      backgroundColor: r.raised,
      borderWidth: 0.0,
      borderRadius: const .vertical(bottom: .circular(12)),
      padding: const .all(16),
    ),
  );
}

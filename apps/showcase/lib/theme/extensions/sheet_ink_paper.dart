// ignore_for_file: implementation_imports
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet_style.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet_theme.dart';

import '../ink_paper_tokens.dart';

/// Sheet overrides for Ink and Paper.
///
/// Default: raised fill, 12 px top radius (`rounded-t-[12px] rounded-b-none`),
/// `px-4 pb-5` padding with 8 px top space for the grabber (`mt-2`), and no
/// border. Neobrutalism: raised fill, 2.5 px ink border, zero radius, and
/// control-border grabber.
JustSheetTheme sheetInkPaper(JustThemePreset preset, InkPaperRoles r) {
  if (preset == .neobrutalism) {
    final JustSheetStyle neoStyle = JustSheetStyle(
      backgroundColor: r.raised,
      borderColor: r.textPrimary,
      borderWidth: 2.5,
      borderRadius: .zero,
      padding: const .fromLTRB(16, 8, 16, 20),
      handleColor: r.borderControl,
    );
    return JustSheetTheme(
      bottomStyle: neoStyle,
      topStyle: neoStyle,
      leftStyle: neoStyle,
      rightStyle: neoStyle,
    );
  }
  return JustSheetTheme(
    bottomStyle: JustSheetStyle(
      backgroundColor: r.raised,
      borderWidth: 0.0,
      borderRadius: const .vertical(top: .circular(12)),
      padding: const .fromLTRB(16, 8, 16, 20),
      handleColor: r.borderControl,
    ),
    topStyle: JustSheetStyle(
      backgroundColor: r.raised,
      borderWidth: 0.0,
      borderRadius: const .vertical(bottom: .circular(12)),
      padding: const .all(16),
      handleColor: r.borderControl,
    ),
    leftStyle: JustSheetStyle(
      backgroundColor: r.raised,
      borderWidth: 0.0,
      borderRadius: const .horizontal(right: .circular(12)),
      padding: const .all(16),
      handleColor: r.borderControl,
    ),
    rightStyle: JustSheetStyle(
      backgroundColor: r.raised,
      borderWidth: 0.0,
      borderRadius: const .horizontal(left: .circular(12)),
      padding: const .all(16),
      handleColor: r.borderControl,
    ),
  );
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area.dart';

import '../../theme/ink_paper_theme.dart';
import '../scene.dart';
import 'control_box.dart';

/// Folders `justui add` writes for three parts (`partDir` in
/// `apps/docs/src/lib/parts.ts`: the CLI's `lib/widgets` plus the slug).
const List<String> _lines = <String>[
  'lib/widgets/button/',
  'lib/widgets/card/',
  'lib/widgets/input/',
];

/// Part scroll-area: three part folders in a framed scroll area, like
/// `KitPart` `scroll-area`.
///
/// All three lines fit, as in the docs demo, so there is nothing to scroll.
/// Core's scroll area still owns a focus node for arrow-key scrolling, and
/// it shows no focus ring; [ExcludeFocus] keeps that empty, unmarked stop
/// out of the Tab order (the docs demo is not focusable either).
Widget scrollAreaScene(BuildContext context, SceneContext scene) {
  final JustSpacingScheme spacing = context.justSpacing;
  return ControlBox(
    // w-52.5 of the docs demo.
    width: 210,
    child: ExcludeFocus(
      child: JustScrollArea(
        smoothScroll: false,
        padding: .fromLTRB(spacing.md, spacing.sm, spacing.xl, spacing.sm),
        child: DefaultTextStyle(
          style: context.justTypo.caption.copyWith(
            fontFamily: InkPaperTheme.monoFontFamily,
            color: context.justColors.textSecondary,
            height: 22 / 12,
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: <Widget>[for (final String line in _lines) Text(line)],
          ),
        ),
      ),
    ),
  );
}

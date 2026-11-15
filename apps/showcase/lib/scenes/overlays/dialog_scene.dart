// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog.dart';

import '../../theme/ink_paper_theme.dart';
import '../scene.dart';

/// Part 29, dialog: an inline confirmation card with a destructive action,
/// matching `KitPart` `dialog` (`KitDialog`, `max-w-62.5`).
Widget dialogScene(BuildContext context, SceneContext scene) {
  final String title = scene.strings.text('discardTitle');
  return Semantics(
    container: true,
    explicitChildNodes: true,
    label: title,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: JustDialogSurface(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontFamily: InkPaperTheme.fontFamily,
                fontSize: 15,
                fontWeight: .w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: .end,
              children: <Widget>[
                JustButton(
                  label: scene.strings.text('cancel'),
                  variant: .secondary,
                  size: .sm,
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                JustButton(
                  label: scene.strings.text('discard'),
                  variant: .destructive,
                  size: .sm,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

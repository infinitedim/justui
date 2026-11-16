// ignore_for_file: implementation_imports
import 'package:material_ui/material_ui.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/toast/just_toast.dart';

import '../../theme/ink_paper_theme.dart';
import '../scene.dart';

/// Part 29, toast: a static success notification card, like `KitPart`
/// `toast` (`KitToast`).
Widget toastScene(BuildContext context, SceneContext scene) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 240),
    child: JustToastSurface(
      variant: .success,
      message: scene.strings.text('saved'),
      description: scene.strings.text('savedBody'),
      icon: Icon(
        Icons.check_circle_outline,
        color: context.justColors.success,
        size: 18,
      ),
      descriptionTextStyle: TextStyle(
        fontFamily: InkPaperTheme.fontFamily,
        fontSize: 13,
        height: 18 / 13,
        color: context.justColors.textSecondary,
      ),
      showCloseButton: false,
      liveRegion: false,
    ),
  );
}

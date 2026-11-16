// ignore_for_file: implementation_imports
import 'package:material_ui/material_ui.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/button/just_icon_button.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip.dart';

import '../scene.dart';

/// Part 32, tooltip: a static tooltip bubble above an icon button, like
/// `KitPart` `tooltip` (`KitTooltip`).
///
/// The static bubble sits inside [ExcludeSemantics] so screen readers announce
/// the icon button's [JustIconButton.tooltip] label only once.
Widget tooltipScene(BuildContext context, SceneContext scene) {
  final String label = scene.strings.text('copy');
  return Column(
    mainAxisSize: .min,
    children: <Widget>[
      ExcludeSemantics(child: JustTooltipBubble(message: label)),
      const SizedBox(height: 8),
      JustIconButton(
        icon: const Icon(Icons.copy, size: 16),
        tooltip: label,
        variant: .secondary,
        onPressed: () {},
      ),
    ],
  );
}

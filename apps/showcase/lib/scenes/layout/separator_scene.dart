// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/separator/just_separator.dart';

import '../scene.dart';

/// Part separator: a vertical rule between the first two tab labels, like
/// `KitPart` `separator`.
Widget separatorScene(BuildContext context, SceneContext scene) {
  final List<String> tabs = scene.strings.list('tabs');
  final TextStyle label = context.justTypo.bodySm.copyWith(
    color: context.justColors.textPrimary,
    fontWeight: .w500,
  );
  final double gap = context.justSpacing.md;
  return Row(
    mainAxisSize: .min,
    children: <Widget>[
      Text(tabs.isNotEmpty ? tabs[0] : '', style: label),
      SizedBox(width: gap),
      // h-5 of the docs demo.
      const JustSeparator(direction: .vertical, height: 20),
      SizedBox(width: gap),
      Text(tabs.length > 1 ? tabs[1] : '', style: label),
    ],
  );
}

// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/button/just_icon_button.dart';

import '../scene.dart';

/// Part 14, icon-button: a square secondary button that holds one plus
/// icon, like `KitPart` `icon-button` (`KitIconButton`, size 40).
///
/// The tooltip is the accessible name, the `aria-label` of the React demo.
Widget iconButtonScene(BuildContext context, SceneContext scene) {
  return JustIconButton(
    icon: const Icon(Icons.add),
    tooltip: scene.strings.text('add'),
    variant: .secondary,
    onPressed: () {},
  );
}

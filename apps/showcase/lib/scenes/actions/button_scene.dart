// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';

import '../scene.dart';

/// Part 07, button: one primary action, like `KitPart` `button`.
///
/// The Row keeps the button at its content width: core's button fills any
/// bounded width it is given, as it would in a user's own Row.
Widget buttonScene(BuildContext context, SceneContext scene) {
  return Row(
    mainAxisSize: .min,
    children: <Widget>[
      JustButton(label: scene.strings.text('saveChanges'), onPressed: () {}),
    ],
  );
}

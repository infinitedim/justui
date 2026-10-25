// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion_style.dart';

import '../scene.dart';
import 'display_look.dart';

/// Part 01, accordion: one question that opens its answer, like `KitPart`
/// `accordion`. It starts closed, as the React demo does; the 240 px cap is
/// the demo's `max-w-60`.
///
/// Like the React demo it sits between two separator lines with no fill.
/// Core's flush variant draws lines only between items and fills each
/// item, so the scene adds the lines and clears the fills.
Widget accordionScene(BuildContext context, SceneContext scene) {
  final DisplayLook look = DisplayLook.of(context);
  // `--ip-part-separator` and `--ip-separator-width`; core has no token
  // for the 2 px neobrutalism separator.
  final BorderSide line = BorderSide(
    color: look.bold ? look.roles.textPrimary : look.roles.borderSubtle,
    width: look.bold ? 2 : 1,
  );
  const Color clear = Color(0x00000000);
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 240),
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: line, bottom: line),
      ),
      child: JustAccordion(
        style: const JustAccordionStyle(
          headerBackgroundColor: clear,
          contentBackgroundColor: clear,
          headerPadding: EdgeInsets.symmetric(vertical: 12),
          contentPadding: EdgeInsets.only(bottom: 12),
        ),
        items: <JustAccordionItem>[
          JustAccordionItem(
            title: scene.strings.text('accordionQuestion'),
            content: Text(scene.strings.text('accordionAnswer')),
          ),
        ],
      ),
    ),
  );
}

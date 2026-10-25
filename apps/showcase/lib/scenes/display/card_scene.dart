// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/card/just_card.dart';

import '../../theme/ink_paper_theme.dart';
import '../scene.dart';

/// Part 08, card: a small card with a title and a description, like
/// `KitPart` `card` (`max-w-60`, `p-4`).
///
/// Core's title and description start from the static `JustTypo` styles,
/// not the theme typography, so the Ink and Paper family goes in with the
/// size and weight.
Widget cardScene(BuildContext context, SceneContext scene) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 240),
    // Core's default card padding is the 16 px of `p-4`.
    child: JustCard(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: <Widget>[
          JustCardTitle(
            style: const TextStyle(
              fontFamily: InkPaperTheme.fontFamily,
              fontSize: 15,
              fontWeight: .w700,
            ),
            child: Text(scene.strings.text('notifications')),
          ),
          const SizedBox(height: 4),
          JustCardDescription(
            style: const TextStyle(
              fontFamily: InkPaperTheme.fontFamily,
              fontSize: 13,
              height: 19 / 13,
            ),
            child: Text(scene.strings.text('notificationsBody')),
          ),
        ],
      ),
    ),
  );
}

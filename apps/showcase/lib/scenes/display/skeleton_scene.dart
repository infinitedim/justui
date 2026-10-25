// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/skeleton/just_skeleton.dart';

import '../scene.dart';

/// Part 25, skeleton: a circle and two bars, like `KitPart` `skeleton`.
///
/// Static, as in the React demo: the Ink and Paper skeleton theme sets a
/// zero duration. Placeholders carry no content, so they stay out of the
/// semantics tree (`aria-hidden` in React).
Widget skeletonScene(BuildContext context, SceneContext scene) {
  return ExcludeSemantics(
    child: Row(
      mainAxisSize: .min,
      children: <Widget>[
        const JustSkeleton.circle(size: 40),
        const SizedBox(width: 12),
        // Up to 150 px, narrower in a tight stage: the second bar keeps
        // two thirds of the first.
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: const Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: <Widget>[
                JustSkeleton.rect(width: double.infinity, height: 12),
                SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 2 / 3,
                  child: JustSkeleton.rect(width: double.infinity, height: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

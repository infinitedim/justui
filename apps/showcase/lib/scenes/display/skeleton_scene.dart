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
  return const ExcludeSemantics(
    child: Row(
      mainAxisSize: .min,
      children: <Widget>[
        JustSkeleton.circle(size: 40),
        SizedBox(width: 12),
        Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: <Widget>[
            JustSkeleton.rect(width: 150, height: 12),
            SizedBox(height: 8),
            JustSkeleton.rect(width: 100, height: 12),
          ],
        ),
      ],
    ),
  );
}

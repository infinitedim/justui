// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart' show JustProgressSize;
import 'package:just_ui_core/src/components/progress/just_progress.dart';

import '../scene.dart';
import 'display_look.dart';

const int _percent = 65;

/// Part 16, progress: a labeled determinate bar at 65 percent, like
/// `KitPart` `progress` (`max-w-55`).
///
/// The label row sits above the bar as in the React demo. Core labels its
/// bar "Progress indicator" in English, so one node carries the localized
/// label and the value instead.
Widget progressScene(BuildContext context, SceneContext scene) {
  final DisplayLook look = DisplayLook.of(context);
  final String label = scene.strings.text('uploading');
  final TextStyle labelStyle = TextStyle(
    fontSize: 13,
    fontWeight: look.strongWeight,
    color: look.roles.textPrimary,
  );
  return Semantics(
    container: true,
    label: label,
    value: '$_percent%',
    child: ExcludeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: .spaceBetween,
              children: <Widget>[
                Text(label, style: labelStyle),
                Text('$_percent%', style: labelStyle),
              ],
            ),
            const SizedBox(height: 8),
            JustProgress(
              value: _percent / 100,
              // React: an 8 px bar, 12 px with the ink outline in neobrutalism.
              size: look.neo ? JustProgressSize.lg : JustProgressSize.md,
              animationDuration: Duration.zero,
            ),
          ],
        ),
      ),
    ),
  );
}

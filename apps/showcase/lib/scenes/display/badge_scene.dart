// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/badge/just_badge.dart';
import 'package:just_ui_core/src/components/badge/just_badge_style.dart';

import '../scene.dart';
import 'display_look.dart';

/// Part 04, badge: two neutral pills, like `KitPart` `badge`.
///
/// Status colors never go on badges (design spec 5.3), so both use the
/// neutral pill: sunken fill and subtle outline in default, surface fill in
/// neobrutalism, where core adds the ink outline itself. Core has no badge
/// theme extension, so the look comes in per instance.
Widget badgeScene(BuildContext context, SceneContext scene) {
  final DisplayLook look = DisplayLook.of(context);
  return Row(
    mainAxisSize: .min,
    children: <Widget>[
      _pill(look, scene.strings.text('draft')),
      const SizedBox(width: 8),
      _pill(look, 'v2'),
    ],
  );
}

JustBadge _pill(DisplayLook look, String label) {
  return JustBadge(
    label: label,
    color: .neutral,
    variant: .outline,
    style: JustBadgeStyle(
      backgroundColor: look.neo ? look.roles.surface : look.roles.sunken,
      foregroundColor: look.roles.textPrimary,
      borderColor: look.roles.borderSubtle,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      textStyle: TextStyle(
        fontSize: 12,
        fontWeight: look.strongWeight,
        color: look.roles.textPrimary,
      ),
    ),
  );
}

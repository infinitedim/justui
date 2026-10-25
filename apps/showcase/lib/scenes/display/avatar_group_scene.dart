// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar_group.dart';

import '../scene.dart';
import 'avatar_scene.dart';
import 'display_look.dart';

/// Part 03, avatar-group: three overlapping avatars, the last one a `+3`
/// count, like `KitPart` `avatar-group`.
///
/// The count is a plain third avatar, as in the React demo. Core's own
/// overflow avatar would read `+` only (its initials keep the first letter
/// of a one-word name), so the group shows all three and never overflows.
Widget avatarGroupScene(BuildContext context, SceneContext scene) {
  final DisplayLook look = DisplayLook.of(context);
  return JustAvatarGroup(
    overlap: 10,
    avatars: <JustAvatar>[
      for (final String initials in const <String>['JU', 'MA', '+3'])
        initialsAvatar(look, initials),
    ],
  );
}

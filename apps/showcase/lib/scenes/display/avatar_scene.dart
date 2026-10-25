// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar_style.dart';

import '../scene.dart';
import 'display_look.dart';

/// Part 02, avatar: an initials avatar next to a label, like `KitPart`
/// `avatar`.
Widget avatarScene(BuildContext context, SceneContext scene) {
  final DisplayLook look = DisplayLook.of(context);
  return Row(
    mainAxisSize: .min,
    children: <Widget>[
      initialsAvatar(look, 'JU'),
      const SizedBox(width: 10),
      Text(
        'just_ui',
        style: TextStyle(
          fontSize: 14,
          fontWeight: .w500,
          color: look.roles.textPrimary,
        ),
      ),
    ],
  );
}

/// A 40 px avatar showing [initials] on a sunken circle.
///
/// Core derives initials from a name (first letters of the first and last
/// word), so the two letters go in as two words; the semantics label keeps
/// the initials as written. Core has no avatar theme extension, so the Ink
/// and Paper fill and outline come in as a per-instance style instead of
/// core's name-hashed palette colors.
JustAvatar initialsAvatar(DisplayLook look, String initials) {
  return JustAvatar(
    name: initials.split('').join(' '),
    semanticLabel: initials,
    style: JustAvatarStyle(
      backgroundColor: look.roles.sunken,
      foregroundColor: look.roles.textPrimary,
      borderColor: look.containerBorder,
      borderWidth: look.line,
    ),
  );
}

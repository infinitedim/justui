// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/avatar/just_avatar.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar_variants.dart';

@widgetbook.UseCase(name: 'Default Avatar', type: JustAvatar)
Widget buildJustAvatarDefaultUseCase(BuildContext context) {
  final String name = context.knobs.string(
    label: 'Name (Initials)',
    initialValue: 'Antigravity AI',
  );
  final JustAvatarSize size = context.knobs.object.dropdown<JustAvatarSize>(
    label: 'Size',
    options: JustAvatarSize.values,
    initialOption: JustAvatarSize.md,
  );
  final JustAvatarShape shape = context.knobs.object.dropdown<JustAvatarShape>(
    label: 'Shape',
    options: JustAvatarShape.values,
    initialOption: JustAvatarShape.circle,
  );
  final JustAvatarStatus? statusDot = context.knobs.objectOrNull
      .dropdown<JustAvatarStatus>(
        label: 'Status Dot',
        options: JustAvatarStatus.values,
        initialOption: JustAvatarStatus.online,
      );

  return Center(
    child: Padding(
      padding: const .all(24.0),
      child: JustAvatar(
        name: name,
        size: size,
        shape: shape,
        statusDot: statusDot,
      ),
    ),
  );
}

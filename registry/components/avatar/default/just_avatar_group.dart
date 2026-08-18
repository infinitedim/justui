import 'package:flutter/widgets.dart';

import '../../theme/theme_provider.dart';
import 'just_avatar.dart';
import 'just_avatar_variants.dart';

/// A widget that displays a group of [JustAvatar]s stacked/overlapped horizontally.
class const JustAvatarGroup({
  super.key,
  required final List<JustAvatar> avatars,
  final int maxDisplay = 3,
  final double overlap = 8.0,
  final JustAvatarSize size = .md,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final customTheme = JustThemeProvider.of(context).theme;
    final presetTokens = customTheme.presetTokens;

    final int displayCount = avatars.length > maxDisplay
        ? maxDisplay
        : avatars.length;
    final int remaining = avatars.length - displayCount;
    final int totalItems = displayCount + (remaining > 0 ? 1 : 0);

    // Resolve diameter for size to calculate layout bounds.
    double diameter;
    switch (size) {
      case .xs:
        diameter = 24.0;
        break;
      case .sm:
        diameter = 32.0;
        break;
      case .md:
        diameter = 40.0;
        break;
      case .lg:
        diameter = 48.0;
        break;
      case .xl:
        diameter = 64.0;
        break;
      case .xxl:
        diameter = 96.0;
        break;
    }

    final double stepWidth = diameter - overlap;
    final double totalWidth = diameter + (totalItems - 1) * stepWidth;

    final List<Widget> children = [];

    // Build stack items in reverse order so that the first avatar is on top
    for (int i = totalItems - 1; i >= 0; i--) {
      final double leftOffset = i * stepWidth;
      Widget item;

      if (i < displayCount) {
        final original = avatars[i];
        item = JustAvatar(
          key: original.key,
          imageUrl: original.imageUrl,
          name: original.name,
          icon: original.icon,
          size: size,
          shape: original.shape,
          border:
              original.border ??
              BorderSide(
                color: colors.background,
                width: presetTokens.borderWidth,
              ),
          statusDot: original.statusDot,
          backgroundColor: original.backgroundColor,
          onTap: original.onTap,
          semanticLabel: original.semanticLabel,
          style: original.style,
        );
      } else {
        item = JustAvatar(
          key: const ValueKey('remaining_avatar'),
          name: '+$remaining',
          size: size,
          shape: avatars.isNotEmpty ? avatars.first.shape : .circle,
          backgroundColor: colors.borderDefault,
          border: BorderSide(
            color: colors.background,
            width: presetTokens.borderWidth,
          ),
        );
      }

      children.add(
        Positioned(left: leftOffset, top: 0.0, bottom: 0.0, child: item),
      );
    }

    return Semantics(
      label: 'Avatar Group of ${avatars.length} users',
      child: SizedBox(
        width: totalWidth,
        height: diameter,
        child: Stack(clipBehavior: .none, children: children),
      ),
    );
  }
}

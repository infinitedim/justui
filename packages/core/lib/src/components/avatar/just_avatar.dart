import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import '../../theme/theme_provider.dart';
import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import 'just_avatar_style.dart';
import 'just_avatar_variants.dart';

/// A custom fallback painter that draws a head-and-shoulders person profile.
///
/// Avoids external dependencies on Material icons.
class PersonFallbackPainter extends CustomPainter {
  /// The color of the fallback graphic.
  final Color color;

  /// Creates a [PersonFallbackPainter].
  const PersonFallbackPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = .fill;

    // Draw head (circle)
    final headRadius = size.width * 0.22;
    final headCenter = Offset(size.width * 0.5, size.height * 0.35);
    canvas.drawCircle(headCenter, headRadius, paint);

    // Draw shoulders (quadratic bezier curve)
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.58,
        size.width * 0.85,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.95,
        size.width * 0.15,
        size.height * 0.85,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PersonFallbackPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// An avatar component for displaying user profile photos, initials, or fallback icons.
class JustAvatar extends StatelessWidget {
  /// The network image URL.
  final String? imageUrl;

  /// The user's name used to automatically generate initials and a deterministic background color.
  final String? name;

  /// Optional custom icon data if initials/images are not available.
  final IconData? icon;

  /// The physical size classification.
  final JustAvatarSize size;

  /// The outer border shape.
  final JustAvatarShape shape;

  /// Custom border configurations.
  final BorderSide? border;

  /// Optional presence status dot.
  final JustAvatarStatus? statusDot;

  /// Custom background color override.
  final Color? backgroundColor;

  /// Callback executed when the avatar is tapped.
  final VoidCallback? onTap;

  /// Accessibility semantic description.
  final String? semanticLabel;

  /// Custom per-instance styles.
  final JustAvatarStyle? style;

  /// Creates a [JustAvatar].
  const JustAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.size = .md,
    this.shape = .circle,
    this.border,
    this.statusDot,
    this.backgroundColor,
    this.onTap,
    this.semanticLabel,
    this.style,
  });

  /// Generate 1-2 letters from a name.
  static String _generateInitials(String? name) {
    if (name == null) return '';
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Generate a deterministic background color from a name.
  static Color _colorFromName(String name) {
    const colors = [
      JustColorPalette.primary500,
      JustColorPalette.success500,
      JustColorPalette.warning500,
      JustColorPalette.error500,
      JustColorPalette.info500,
      JustColorPalette.neutral500,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final radius = theme.radius;

    // Resolve diameter, font size, status dot size
    double diameter;
    double fontSize;
    double dotSize;

    switch (size) {
      case .xs:
        diameter = 24.0;
        fontSize = 10.0;
        dotSize = 6.0;
        break;
      case .sm:
        diameter = 32.0;
        fontSize = 12.0;
        dotSize = 8.0;
        break;
      case .md:
        diameter = 40.0;
        fontSize = 14.0;
        dotSize = 10.0;
        break;
      case .lg:
        diameter = 48.0;
        fontSize = 16.0;
        dotSize = 12.0;
        break;
      case .xl:
        diameter = 64.0;
        fontSize = 20.0;
        dotSize = 14.0;
        break;
      case .xxl:
        diameter = 96.0;
        fontSize = 28.0;
        dotSize = 18.0;
        break;
    }

    // Resolve shape border radius
    final BorderRadius borderRadius = shape == .circle
        ? .all(radius.full)
        : .all(radius.xl);

    // Resolve colors & overrides
    final initials = _generateInitials(name);
    final Color bg =
        style?.backgroundColor ??
        backgroundColor ??
        (name != null ? _colorFromName(name!) : colors.borderDefault);
    final Color fg = style?.foregroundColor ?? colors.textInverse;
    final presetTokens = theme.presetTokens;
    final double borderWidth =
        style?.borderWidth ??
        border?.width ??
        (presetTokens.showsDefaultBorder ? presetTokens.borderWidth : 0.0);
    final Color borderColor =
        style?.borderColor ??
        border?.color ??
        (presetTokens.showsDefaultBorder
            ? colors.borderDefault
            : const Color(0x00000000));

    // Build core content: Network Image -> Initials -> Icon
    Widget content;
    if (imageUrl != null) {
      content = Image.network(
        imageUrl!,
        fit: .cover,
        width: diameter,
        height: diameter,
        errorBuilder: (_, _, _) =>
            _buildFallback(initials, fg, diameter, fontSize),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _buildFallback(initials, fg, diameter, fontSize);
        },
      );
    } else {
      content = _buildFallback(initials, fg, diameter, fontSize);
    }

    // Wrap with clip to follow shape radius boundaries
    Widget avatarBody = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        border: borderWidth > 0.0
            ? .all(color: borderColor, width: borderWidth)
            : null,
      ),
      child: ClipRRect(borderRadius: borderRadius, child: content),
    );

    // Wrap with status indicator if present
    if (statusDot != null) {
      Color statusColor;
      switch (statusDot!) {
        case .online:
          statusColor = JustColorPalette.success500;
          break;
        case .offline:
          statusColor = JustColorPalette.neutral400;
          break;
        case .away:
          statusColor = JustColorPalette.warning500;
          break;
        case .busy:
          statusColor = JustColorPalette.error500;
          break;
      }

      avatarBody = SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          clipBehavior: .none,
          children: [
            avatarBody,
            Positioned(
              right: 0.0,
              bottom: 0.0,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: .circle,
                  border: .all(color: const Color(0xFFFFFFFF), width: 1.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Wrap tap trigger
    if (onTap != null) {
      return Semantics(
        button: true,
        enabled: true,
        label: semanticLabel ?? name ?? 'Avatar',
        image: imageUrl != null,
        child: JustPressable(
          enabled: true,
          onTap: onTap,
          builder: (BuildContext context, JustInteractionState state) {
            return FocusIndicator(
              isFocused: state.isFocusVisible,
              borderRadius: borderRadius,
              child: avatarBody,
            );
          },
        ),
      );
    }

    return Semantics(
      label: semanticLabel ?? name ?? 'Avatar',
      image: imageUrl != null,
      child: avatarBody,
    );
  }

  Widget _buildFallback(
    String initials,
    Color fg,
    double size,
    double fontSize,
  ) {
    if (initials.isNotEmpty) {
      return Center(
        child: Text(
          initials,
          style: TextStyle(fontSize: fontSize, fontWeight: .w600, color: fg),
        ),
      );
    }

    if (icon != null) {
      return Center(
        child: Text(
          String.fromCharCode(icon!.codePoint),
          style: TextStyle(
            fontSize: fontSize + 6.0,
            fontFamily: icon!.fontFamily,
            package: icon!.fontPackage,
            color: fg,
          ),
        ),
      );
    }

    // Primitive custom shape painter person fallback
    return Center(
      child: SizedBox(
        width: size * 0.8,
        height: size * 0.8,
        child: CustomPaint(
          painter: PersonFallbackPainter(color: fg.withValues(alpha: 0.8)),
        ),
      ),
    );
  }
}

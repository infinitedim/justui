import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import 'just_badge_style.dart';
import 'just_badge_variants.dart';

/// A badge component for showing status, counts, or small tags.
/// A badge component for showing status, counts, or small tags.
class const JustBadge({
  super.key,

  /// The text label of the badge. Null represents a notification dot badge.
  final String? label,

  /// The color category classification.
  final JustBadgeColor color = .primary,

  /// The visual style variant.
  final JustBadgeVariant variant = .solid,

  /// The physical size classification.
  final JustBadgeSize size = .md,

  /// An optional icon or widget displayed before the label.
  final Widget? leading,

  /// Optional callback to dismiss the badge. If non-null, displays a close icon at the end.
  final VoidCallback? onDismiss,

  /// Optional maximum width constraint. Text will truncate with ellipsis if exceeded.
  final double? maxWidth,

  /// Per-instance style overrides.
  final JustBadgeStyle? style,

  /// Whether to show a pulse animation (only applicable to dot variant).
  final bool pulse = false,
}) extends StatelessWidget {
  /// Shorthand constructor for notification dot badges.
  const new dot({
    Key? key,
    JustBadgeColor color = .error,
    JustBadgeSize size = .sm,
    bool pulse = false,
  }) : this(
         key: key,
         label: null,
         color: color,
         variant: .dot,
         size: size,
         leading: null,
         onDismiss: null,
         maxWidth: null,
         style: null,
         pulse: pulse,
       );

  /// Convenience utility to overlay a positioned badge on top of another widget.
  static Widget overlay({
    required Widget child,
    required JustBadge badge,
    BadgePosition position = .topRight,
  }) {
    double? top;
    double? bottom;
    double? left;
    double? right;

    switch (position) {
      case .topRight:
        top = -6.0;
        right = -6.0;
        break;
      case .topLeft:
        top = -6.0;
        left = -6.0;
        break;
      case .bottomRight:
        bottom = -6.0;
        right = -6.0;
        break;
      case .bottomLeft:
        bottom = -6.0;
        left = -6.0;
        break;
    }

    return Stack(
      clipBehavior: .none,
      children: [
        child,
        Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: badge,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = theme.radius;

    // Resolve sizes
    double height;
    double paddingH;
    TextStyle textStyle;
    double dotSize;
    BorderRadius defaultRadius;

    switch (size) {
      case .sm:
        height = 18.0;
        paddingH = 6.0;
        textStyle = typography.caption.copyWith(
          fontSize: 11.0,
          fontWeight: .w500,
        );
        dotSize = 6.0;
        defaultRadius = .all(radius.sm);
        break;
      case .md:
        height = 22.0;
        paddingH = 8.0;
        textStyle = typography.caption.copyWith(
          fontSize: 12.0,
          fontWeight: .w500,
        );
        dotSize = 8.0;
        defaultRadius = .all(radius.sm);
        break;
      case .lg:
        height = 26.0;
        paddingH = 10.0;
        textStyle = typography.caption.copyWith(
          fontSize: 13.0,
          fontWeight: .w500,
        );
        dotSize = 10.0;
        defaultRadius = .all(radius.md);
        break;
    }

    // Resolve color variables based on JustBadgeColor and JustBadgeVariant
    Color bg;
    Color fg;
    Color border = const Color(0x00000000);

    final primaryBg = theme.presetTokens.showsDefaultBorder
        ? colors.warning
        : colors.borderFocus;
    final primaryFg = theme.presetTokens.showsDefaultBorder
        ? colors.textPrimary
        : colors.textInverse;
    final textPrimary = colors.textPrimary;
    final textSecondary = colors.textSecondary;
    final borderDefault = colors.borderDefault;

    switch (color) {
      case .primary:
        if (variant == .solid) {
          bg = primaryBg;
          fg = primaryFg;
        } else if (variant == .soft) {
          bg = primaryBg.withValues(alpha: 0.1);
          fg = primaryBg;
        } else {
          bg = const Color(0x00000000);
          border = primaryBg;
          fg = primaryBg;
        }
        break;

      case .secondary:
        if (variant == .solid) {
          bg = textPrimary;
          fg = primaryFg;
        } else if (variant == .soft) {
          bg = textPrimary.withValues(alpha: 0.1);
          fg = textPrimary;
        } else {
          bg = const Color(0x00000000);
          border = borderDefault;
          fg = textPrimary;
        }
        break;

      case .success:
        final c = colors.success;
        if (variant == .solid) {
          bg = c;
          fg = primaryFg;
        } else if (variant == .soft) {
          bg = c.withValues(alpha: 0.1);
          fg = c;
        } else {
          bg = const Color(0x00000000);
          border = c;
          fg = c;
        }
        break;

      case .warning:
        final c = colors.warning;
        if (variant == .solid) {
          bg = c;
          fg = primaryFg;
        } else if (variant == .soft) {
          bg = c.withValues(alpha: 0.1);
          fg = c;
        } else {
          bg = const Color(0x00000000);
          border = c;
          fg = c;
        }
        break;

      case .error:
        final c = colors.error;
        if (variant == .solid) {
          bg = c;
          fg = primaryFg;
        } else if (variant == .soft) {
          bg = c.withValues(alpha: 0.1);
          fg = c;
        } else {
          bg = const Color(0x00000000);
          border = c;
          fg = c;
        }
        break;

      case .info:
        final c = colors.info;
        if (variant == .solid) {
          bg = c;
          fg = primaryFg;
        } else if (variant == .soft) {
          bg = c.withValues(alpha: 0.1);
          fg = c;
        } else {
          bg = const Color(0x00000000);
          border = c;
          fg = c;
        }
        break;

      case .neutral:
        if (variant == .solid) {
          bg = textSecondary;
          fg = primaryFg;
        } else if (variant == .soft) {
          bg = textSecondary.withValues(alpha: 0.1);
          fg = textSecondary;
        } else {
          bg = const Color(0x00000000);
          border = borderDefault;
          fg = textSecondary;
        }
        break;
    }

    // Overrides
    final finalBg = style?.backgroundColor ?? bg;
    final finalFg = style?.foregroundColor ?? fg;
    final finalBorder = style?.borderColor ?? border;
    final finalRadius = style?.borderRadius ?? defaultRadius;
    final finalPadding = style?.padding ?? .symmetric(horizontal: paddingH);
    final finalTextStyle =
        style?.textStyle ?? textStyle.copyWith(color: finalFg);

    // Dot variant layout
    if (variant == .dot) {
      final dotColor = finalBg == const Color(0x00000000) ? finalFg : finalBg;
      if (pulse) {
        return _JustPulsingDot(
          size: dotSize,
          color: dotColor,
          pulseScale: style?.pulseScale ?? 2.2,
        );
      }
      return Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(color: dotColor, shape: .circle),
      );
    }

    // Content assembly
    Widget? leadingIcon;
    if (leading != null) {
      leadingIcon = Padding(
        padding: .only(right: spacing.xs),
        child: IconTheme.merge(
          data: IconThemeData(size: finalTextStyle.fontSize, color: finalFg),
          child: leading!,
        ),
      );
    }

    Widget? dismissIcon;
    if (onDismiss != null) {
      dismissIcon = GestureDetector(
        onTap: onDismiss,
        child: Padding(
          padding: .only(left: spacing.xs),
          child: Text('✕', style: finalTextStyle.copyWith(fontSize: 10.0)),
        ),
      );
    }

    Widget labelText = Text(
      label ?? '',
      style: finalTextStyle,
      overflow: .ellipsis,
    );

    if (maxWidth != null) {
      labelText = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: labelText,
      );
    }

    final presetTokens = theme.presetTokens;

    final Border? resolvedBorder = presetTokens.showsDefaultBorder
        ? .all(color: colors.textPrimary, width: presetTokens.borderWidth)
        : (finalBorder != const Color(0x00000000)
              ? .all(color: finalBorder, width: 1.0)
              : null);

    final List<BoxShadow>? resolvedShadows = presetTokens.showsDefaultBorder
        ? (size == .sm ? theme.shadows.xs : theme.shadows.sm)
        : null;

    return Container(
      height: height,
      padding: finalPadding,
      decoration: BoxDecoration(
        color: finalBg,
        borderRadius: finalRadius,
        border: resolvedBorder,
        boxShadow: resolvedShadows,
      ),
      child: Row(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: [?leadingIcon, labelText, ?dismissIcon],
      ),
    );
  }
}

class const _JustPulsingDot({
  required final double size,
  required final Color color,
  required final double pulseScale,
}) extends StatefulWidget {
  @override
  State<_JustPulsingDot> createState() => _JustPulsingDotState();
}

class _JustPulsingDotState extends State<_JustPulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: JustDuration.slower,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Flow(
        delegate: _PulsingFlowDelegate(
          controller: _controller,
          pulseScale: widget.pulseScale,
        ),
        children: [
          // Pulse halo (decorative)
          ExcludeSemantics(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.4),
                shape: .circle,
              ),
            ),
          ),
          // Inner dot
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(color: widget.color, shape: .circle),
          ),
        ],
      ),
    );
  }
}

class _PulsingFlowDelegate extends FlowDelegate {
  final Animation<double> controller;
  final double pulseScale;

  _PulsingFlowDelegate({required this.controller, required this.pulseScale})
    : super(repaint: controller);

  @override
  void paintChildren(FlowPaintingContext context) {
    // 1. Paint pulse halo
    final double scale = 1.0 + (pulseScale - 1.0) * controller.value;
    final double opacity = 1.0 - controller.value;
    final double centerShift =
        (context.size.width - context.size.width * scale) / 2.0;

    context.paintChild(
      0,
      transform: Matrix4.translationValues(centerShift, centerShift, 0.0)
        ..scaleByDouble(scale, scale, 1.0, 1.0),
      opacity: opacity,
    );

    // 2. Paint inner dot (no transformation, full opacity)
    context.paintChild(1);
  }

  @override
  bool shouldRepaint(covariant _PulsingFlowDelegate oldDelegate) {
    return pulseScale != oldDelegate.pulseScale;
  }
}

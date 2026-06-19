import 'package:flutter/widgets.dart';
import '../../theme/theme_provider.dart';

/// A premium, declarative tooltip overlay that positions itself relative to its anchor
/// using the native [OverlayPortal.overlayChildLayoutBuilder] API.
///
/// Under zero-Material dependency constraints, it avoids [CompositedTransformFollower]
/// to prevent debug-mode assertions in newer Flutter versions.
class JustTooltipOverlay extends StatefulWidget {
  /// The message string to display inside the tooltip box.
  final String message;

  /// The anchor child widget that triggers the tooltip on hover.
  final Widget child;

  /// An optional external controller. If null, a local controller is managed internally.
  final OverlayPortalController? controller;

  /// Creates a [JustTooltipOverlay] widget.
  const JustTooltipOverlay({
    super.key,
    required this.message,
    required this.child,
    this.controller,
  });

  @override
  State<JustTooltipOverlay> createState() => _JustTooltipOverlayState();
}

class _JustTooltipOverlayState extends State<JustTooltipOverlay> {
  late OverlayPortalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? OverlayPortalController();
  }

  @override
  void didUpdateWidget(covariant JustTooltipOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? OverlayPortalController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(context, aspect: .typography).theme.typography;
    final spacing = JustThemeProvider.of(context, aspect: .spacing).theme.spacing;
    final radius = JustThemeProvider.of(context).theme.radius;

    return MouseRegion(
      onEnter: (_) => _controller.show(),
      onExit: (_) => _controller.hide(),
      child: OverlayPortal.overlayChildLayoutBuilder(
        controller: _controller,
        overlayChildLayoutBuilder: (context, info) {
          // Calculate the target offset relative to the overlay coordinate system
          final targetOffset = MatrixUtils.transformPoint(info.childPaintTransform, Offset.zero);

          // We estimate tooltip height to be ~24px for positioning.
          // Positioning: placed to the right of the trigger child (useful for collapsed sidebar items).
          return Positioned(
            left: targetOffset.dx + info.childSize.width + spacing.sm,
            top: targetOffset.dy + (info.childSize.height - 24.0) / 2,
            child: IgnorePointer(
              child: Container(
                padding: .symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.overlay,
                  borderRadius: .all(radius.xs),
                  boxShadow: JustThemeProvider.of(context).theme.shadows.sm,
                ),
                child: Center(
                  child: Text(
                    widget.message,
                    style: typography.caption.copyWith(
                      color: colors.textInverse,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

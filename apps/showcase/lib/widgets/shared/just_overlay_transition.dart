// justui-meta: registry=8c977d96997c11900fdb5c04ac82ada59064cb7d3e9eaf7122b54500abbc518e local=9ec64bf89034372a17d7ec5e7c76bcf883b430361086ddf791eaeea546e8a18e
import 'package:flutter/widgets.dart';
import 'package:showcase/core/just_ui_core.dart';

/// Reusable overlay entrance/exit animation wrapper.
///
/// Integrates with [JustMotionProfile] to automatically resolve
/// animation duration and curves based on the active theme preset.
/// Respects `MediaQuery.disableAnimationsOf` for accessibility.
///
/// Usage:
/// ```dart
/// JustOverlayTransition(
///   isVisible: _overlayController.isShowing,
///   onExitComplete: () => _overlayController.hide(),
///   child: calendarWidget,
/// )
/// ```
class const JustOverlayTransition({
  super.key,
  required final Widget child,
  required final bool isVisible,
  final VoidCallback? onExitComplete,
  final Duration? duration,
  final Curve? enterCurve,
  final Curve? exitCurve,
  final Alignment scaleAlignment = Alignment.topCenter,
}) extends StatefulWidget {
  @override
  State<JustOverlayTransition> createState() => _JustOverlayTransitionState();
}

class _JustOverlayTransitionState extends State<JustOverlayTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _motionResolved = false;

  @override
  void initState() {
    super.initState();
    // Initialize with a placeholder duration; actual duration is resolved in didChangeDependencies.
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 150),
    );
    _setupAnimations(Curves.easeOutCubic, Curves.easeInCubic);
    if (widget.isVisible) {
      _controller.forward();
    }
  }

  void _setupAnimations(Curve enterCurve, Curve exitCurve) {
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.enterCurve ?? enterCurve,
      reverseCurve: widget.exitCurve ?? exitCurve,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.enterCurve ?? enterCurve,
        reverseCurve: widget.exitCurve ?? exitCurve,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_motionResolved) {
      _motionResolved = true;
      final themeState = JustThemeProvider.maybeOf(
        context,
        aspect: .animations,
      );
      if (themeState != null) {
        final motion = themeState.theme.animations.resolve(context);
        final resolvedDuration = widget.duration ?? motion.fast;
        _controller.duration = resolvedDuration;
        _setupAnimations(motion.enter, motion.exit);
      }
    }
  }

  @override
  void didUpdateWidget(covariant JustOverlayTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse().then((_) {
          widget.onExitComplete?.call();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect reduced motion accessibility setting
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: widget.scaleAlignment,
        child: widget.child,
      ),
    );
  }
}

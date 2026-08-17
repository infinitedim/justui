import 'dart:async';

import 'package:flutter/material.dart' show Icons, Theme;
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import '../../overlay/just_overlay_controller.dart';
import '../../theme/theme_provider.dart';
import 'just_toast_style.dart';
import 'just_toast_theme.dart';
import 'just_toast_variants.dart';

/// Represents a single active toast entry in the overlay.
class _ToastEntry {
  final String id;
  final String message;
  final ToastVariant variant;
  final Duration duration;
  final JustToastStyle? style;
  final Widget? icon;
  final Widget? action;
  final VoidCallback? onDismissed;
  final OverlayEntry overlayEntry;
  final AnimationController animationController;
  late final Timer timer;

  _ToastEntry({
    required this.id,
    required this.message,
    required this.variant,
    required this.duration,
    this.style,
    this.icon,
    this.action,
    this.onDismissed,
    required this.overlayEntry,
    required this.animationController,
  });
}

/// A pending toast waiting in the queue.
class _ToastPending {
  final String message;
  final ToastVariant variant;
  final Duration duration;
  final JustToastStyle? style;
  final Widget? icon;
  final Widget? action;
  final VoidCallback? onDismissed;
  final AnimationController? animationController;
  final JustOverlayAnimationBuilder? animationBuilder;

  _ToastPending({
    required this.message,
    required this.variant,
    required this.duration,
    this.style,
    this.icon,
    this.action,
    this.onDismissed,
    this.animationController,
    this.animationBuilder,
  });
}

/// Imperative controller for managing stacked or queued toasts.
class JustToastController extends JustOverlayController {
  /// The behavior mode (stacked or queue) for multiple toasts.
  final ToastBehavior behavior;

  /// The maximum number of visible toasts in stacked mode.
  final int? limit;

  /// The screen position where toasts are anchored.
  final ToastPosition position;

  /// Whether to enable horizontal swipe-to-dismiss gesture.
  final bool enableDragDismiss;

  OverlayState? _overlayState;
  TickerProvider? _vsync;
  final List<_ToastEntry> _activeToasts = [];
  final List<_ToastPending> _queue = [];

  /// Creates a [JustToastController].
  JustToastController({
    this.behavior = .stacked,
    this.limit = 3,
    this.position = .bottomCenter,
    this.enableDragDismiss = true,
  });

  @override
  bool get isVisible => _activeToasts.isNotEmpty;

  /// Shows a toast notification.
  void show({
    required String message,
    ToastVariant variant = .info,
    Duration duration = const Duration(seconds: 3),
    JustToastStyle? style,
    AnimationController? animationController,
    JustOverlayAnimationBuilder? animationBuilder,
    Widget? icon,
    Widget? action,
    VoidCallback? onDismissed,
  }) {
    assert(
      _overlayState != null,
      'JustToastController must be attached to a JustToastScope before calling show()',
    );
    assert(
      _vsync != null,
      'JustToastController must have a valid TickerProvider from JustToastScope',
    );

    final pending = _ToastPending(
      message: message,
      variant: variant,
      duration: duration,
      style: style,
      icon: icon,
      action: action,
      onDismissed: onDismissed,
      animationController: animationController,
      animationBuilder: animationBuilder,
    );

    if (behavior == .queue) {
      if (_activeToasts.isNotEmpty) {
        _queue.add(pending);
      } else {
        _showToast(pending);
      }
    } else {
      if (limit != null && _activeToasts.length >= limit!) {
        // Dismiss the oldest toast
        _dismissToast(_activeToasts.first);
      }
      _showToast(pending);
    }
  }

  void _showToast(_ToastPending pending) {
    final animController =
        pending.animationController ??
        AnimationController(
          vsync: _vsync!,
          duration: const Duration(milliseconds: 300),
        );

    late final _ToastEntry entry;
    final overlayEntry = OverlayEntry(
      builder: (context) {
        final index = _activeToasts.indexOf(entry);
        if (index == -1) return const SizedBox.shrink();

        final theme = JustThemeProvider.of(context).theme;
        final spacing = theme.spacing;

        // Approximate toast height + spacing for stack offset calculations
        const double toastHeight = 56.0;
        final double toastSpacing = spacing.sm;
        final offset =
            (_activeToasts.length - 1 - index) * (toastHeight + toastSpacing);

        Widget toastCard = _JustToastWidget(
          entry: entry,
          enableDrag: enableDragDismiss,
          onDismiss: () => _dismissToast(entry),
        );

        if (pending.animationBuilder != null) {
          toastCard = pending.animationBuilder!(
            context,
            animController,
            toastCard,
          );
        }

        return RepaintBoundary(
          child: _ToastPositionedWrapper(
            position: position,
            offset: offset,
            animation: animController,
            child: toastCard,
          ),
        );
      },
    );

    entry = _ToastEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: pending.message,
      variant: pending.variant,
      duration: pending.duration,
      style: pending.style,
      icon: pending.icon,
      action: pending.action,
      onDismissed: pending.onDismissed,
      overlayEntry: overlayEntry,
      animationController: animController,
    );

    _activeToasts.add(entry);
    _overlayState!.insert(overlayEntry);

    entry.timer = Timer(pending.duration, () {
      _dismissToast(entry);
    });

    animController.forward();
    _updatePositions();
  }

  void _dismissToast(_ToastEntry entry) {
    if (!_activeToasts.contains(entry)) return;

    entry.timer.cancel();
    entry.animationController.reverse().then((_) {
      entry.overlayEntry.remove();
      entry.overlayEntry.dispose();

      // Only dispose if it was created locally
      final wasLocal =
          !_queue.any(
            (q) => q.animationController == entry.animationController,
          ) &&
          _activeToasts
              .where(
                (t) =>
                    t != entry &&
                    t.animationController == entry.animationController,
              )
              .isEmpty;
      if (wasLocal) {
        entry.animationController.dispose();
      }

      _activeToasts.remove(entry);
      if (entry.onDismissed != null) {
        entry.onDismissed!();
      }

      _updatePositions();

      if (behavior == .queue && _queue.isNotEmpty) {
        _showToast(_queue.removeAt(0));
      }
    });
  }

  void _updatePositions() {
    for (final toast in _activeToasts) {
      toast.overlayEntry.markNeedsBuild();
    }
  }

  @override
  void dismiss() {
    final targets = List<_ToastEntry>.from(_activeToasts);
    for (final toast in targets) {
      _dismissToast(toast);
    }
  }

  @override
  void dispose() {
    dismiss();
    _queue.clear();
  }
}

/// A wrapper widget that handles the slide/fade entrance and vertical staggering.
class _ToastPositionedWrapper extends StatelessWidget {
  final ToastPosition position;
  final double offset;
  final Animation<double> animation;
  final Widget child;

  const _ToastPositionedWrapper({
    required this.position,
    required this.offset,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final motion = JustThemeProvider.of(
      context,
      aspect: .animations,
    ).theme.animations.resolve(context);
    final double margin = spacing.lg;

    double? left;
    double? right;

    switch (position) {
      case .topLeft:
      case .bottomLeft:
        left = margin;
        right = null;
        break;
      case .topRight:
      case .bottomRight:
        left = null;
        right = margin;
        break;
      case .topCenter:
      case .bottomCenter:
        left = 0.0;
        right = 0.0;
        break;
    }

    double? top;
    double? bottom;
    final isTop =
        position == .topLeft || position == .topCenter || position == .topRight;

    if (isTop) {
      top = margin + offset;
      bottom = null;
    } else {
      top = null;
      bottom = margin + offset;
    }

    Widget positionedChild = child;
    if (position == .topCenter || position == .bottomCenter) {
      positionedChild = Center(child: child);
    }

    final slideTween = isTop
        ? Tween<Offset>(begin: const Offset(0, -1), end: .zero)
        : Tween<Offset>(begin: const Offset(0, 1), end: .zero);

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: motion.enter,
      reverseCurve: motion.exit,
    );

    return AnimatedPositioned(
      duration: motion.normal,
      curve: motion.defaultCurve,
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: curvedAnimation.drive(slideTween),
          child: positionedChild,
        ),
      ),
    );
  }
}

/// The actual visual card of the Toast, supporting horizontal swipe-to-dismiss.
class _JustToastWidget extends StatefulWidget {
  final _ToastEntry entry;
  final bool enableDrag;
  final VoidCallback onDismiss;

  const _JustToastWidget({
    required this.entry,
    required this.enableDrag,
    required this.onDismiss,
  });

  @override
  State<_JustToastWidget> createState() => _JustToastWidgetState();
}

class _JustToastWidgetState extends State<_JustToastWidget>
    with SingleTickerProviderStateMixin {
  double _dragX = 0.0;
  late AnimationController _swipeBackController;
  late Animation<double> _swipeBackAnimation;

  @override
  void initState() {
    super.initState();
    _swipeBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _swipeBackAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_swipeBackController);
  }

  @override
  void dispose() {
    _swipeBackController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag) return;
    setState(() {
      _dragX += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.enableDrag) return;
    if (_dragX.abs() > 100.0) {
      widget.onDismiss();
    } else {
      _swipeBackAnimation = Tween<double>(begin: _dragX, end: 0.0).animate(
        CurvedAnimation(parent: _swipeBackController, curve: Curves.easeOut),
      );
      _swipeBackController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swipeBackController,
      builder: (context, child) {
        final currentX = _swipeBackController.isAnimating
            ? _swipeBackAnimation.value
            : _dragX;
        final opacity = (1.0 - (currentX.abs() / 300.0)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(currentX, 0.0),
          child: Opacity(
            opacity: opacity,
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: child,
            ),
          ),
        );
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final radius = theme.radius;
    final shadows = theme.shadows;

    final globalTheme = Theme.of(context).extension<JustToastTheme>();

    // Resolve variant style from theme extension
    JustToastStyle? variantThemeStyle;
    switch (widget.entry.variant) {
      case .info:
        variantThemeStyle = globalTheme?.infoStyle;
        break;
      case .success:
        variantThemeStyle = globalTheme?.successStyle;
        break;
      case .warning:
        variantThemeStyle = globalTheme?.warningStyle;
        break;
      case .error:
        variantThemeStyle = globalTheme?.errorStyle;
        break;
    }

    final entryStyle = widget.entry.style;

    // Resolve visual styles
    final bgColor =
        entryStyle?.backgroundColor ??
        variantThemeStyle?.backgroundColor ??
        colors.card;
    final borderColor =
        entryStyle?.borderColor ??
        variantThemeStyle?.borderColor ??
        colors.borderDefault;
    final borderRadius =
        entryStyle?.borderRadius ??
        variantThemeStyle?.borderRadius ??
        .all(radius.md);
    final padding =
        entryStyle?.padding ??
        variantThemeStyle?.padding ??
        .symmetric(horizontal: spacing.md, vertical: spacing.sm);
    final textStyle =
        entryStyle?.textStyle ??
        variantThemeStyle?.textStyle ??
        JustFluidTypo.bodySm(context).copyWith(color: colors.textPrimary);
    final maxWidth =
        entryStyle?.maxWidth ?? variantThemeStyle?.maxWidth ?? 360.0;
    final minWidth =
        entryStyle?.minWidth ?? variantThemeStyle?.minWidth ?? 280.0;
    final toastShadows =
        entryStyle?.shadows ?? variantThemeStyle?.shadows ?? shadows.md;

    // Default icons
    Widget defaultIcon;
    switch (widget.entry.variant) {
      case .success:
        defaultIcon = Icon(
          Icons.check_circle_outline,
          color: colors.success,
          size: 20.0,
        );
        break;
      case .warning:
        defaultIcon = Icon(
          Icons.warning_amber_outlined,
          color: colors.warning,
          size: 20.0,
        );
        break;
      case .error:
        defaultIcon = Icon(
          Icons.error_outline,
          color: colors.error,
          size: 20.0,
        );
        break;
      case .info:
        defaultIcon = Icon(Icons.info_outline, color: colors.info, size: 20.0);
        break;
    }

    final resolvedIcon = widget.entry.icon ?? defaultIcon;

    final presetTokens = theme.presetTokens;
    final borderSide = BorderSide(
      color: presetTokens.showsDefaultBorder ? colors.textPrimary : borderColor,
      width: presetTokens.borderWidth,
    );

    return Semantics(
      liveRegion: true,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth,
          minHeight: 48.0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: .fromBorderSide(borderSide),
          boxShadow: theme.resolveShadows(toastShadows, isPressed: false),
        ),
        padding: padding,
        child: Row(
          mainAxisSize: .min,
          children: [
            resolvedIcon,
            SizedBox(width: spacing.sm),
            Expanded(child: Text(widget.entry.message, style: textStyle)),
            if (widget.entry.action != null) ...[
              SizedBox(width: spacing.sm),
              widget.entry.action!,
            ] else ...[
              SizedBox(width: spacing.sm),
              GestureDetector(
                onTap: widget.onDismiss,
                child: Icon(
                  Icons.close,
                  color: colors.textSecondary,
                  size: 16.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Scope widget that binds a [JustToastController] and handles the Flutter context/ticker binding.
class JustToastScope extends StatefulWidget {
  /// The controller that manages the toast notifications.
  final JustToastController controller;

  /// The child subtree.
  final Widget child;

  /// Creates a [JustToastScope].
  const JustToastScope({
    super.key,
    required this.controller,
    required this.child,
  });

  /// Retrieves the nearest [JustToastController] from the ancestor scope.
  static JustToastController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_JustToastScopeInherited>();
    assert(scope != null, 'No JustToastScope found in context');
    return scope!.controller;
  }

  @override
  State<JustToastScope> createState() => _JustToastScopeState();
}

class _JustToastScopeState extends State<JustToastScope>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller._vsync = this;
  }

  @override
  void didUpdateWidget(covariant JustToastScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller._vsync = null;
      oldWidget.controller._overlayState = null;
      widget.controller._vsync = this;
      widget.controller._overlayState = Overlay.of(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller._overlayState = Overlay.of(context);
  }

  @override
  void dispose() {
    widget.controller._vsync = null;
    widget.controller._overlayState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _JustToastScopeInherited(
      controller: widget.controller,
      child: widget.child,
    );
  }
}

class _JustToastScopeInherited extends InheritedWidget {
  final JustToastController controller;

  const _JustToastScopeInherited({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_JustToastScopeInherited oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Context extensions to easily access toast functionality.
extension JustToastContextExtension on BuildContext {
  /// Retrieves the nearest [JustToastController] for showing toast notifications.
  JustToastController get justToast => JustToastScope.of(this);
}

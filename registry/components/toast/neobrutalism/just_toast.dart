import 'dart:async';

import 'package:flutter/material.dart' show Icons, Theme;
import 'package:flutter/scheduler.dart';
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

  /// Set as soon as a dismissal has been requested for this entry, so a
  /// second dismiss request for the same entry (e.g. the auto-dismiss timer
  /// firing while the user is also swiping it away, or a rapid double-tap on
  /// the close affordance) is a no-op instead of starting a second reverse
  /// animation.
  bool _dismissRequested = false;

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

  /// The maximum number of visible toasts in stacked mode, or maximum queued
  /// pending toasts in queue mode.
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
    int? limit,
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

    final effectiveLimit = limit ?? this.limit;

    if (behavior == .queue) {
      if (_activeToasts.isNotEmpty) {
        if (effectiveLimit != null && _queue.length >= effectiveLimit) {
          if (_queue.isNotEmpty) {
            // Drops oldest queued toast when the queue cap is reached
            _queue.removeAt(0);
          }
        }
        if (effectiveLimit == null || effectiveLimit > 0) {
          _queue.add(pending);
        }
      } else {
        _showToast(pending);
      }
    } else {
      if (effectiveLimit != null) {
        // 1. Get non-dismissing active toasts
        final activeVisible = _activeToasts
            .where((t) => !t._dismissRequested)
            .toList();

        // 2. If active visible toasts reach limit, dismiss the oldest active one
        if (activeVisible.length >= effectiveLimit) {
          _dismissToast(activeVisible.first);
        }

        // 3. Immediately clean up any toasts that are already reversing/dismissing
        // if total entries exceed effectiveLimit to prevent overlay accumulation during rapid click spam
        while (_activeToasts.length >= effectiveLimit &&
            _activeToasts.any((t) => t._dismissRequested)) {
          final oldestDismissing = _activeToasts.firstWhere(
            (t) => t._dismissRequested,
          );
          _cleanupToastEntry(oldestDismissing);
        }
      }
      _showToast(pending);
    }
  }

  void _showToast(_ToastPending pending) {
    final animController =
        pending.animationController ??
        AnimationController(vsync: _vsync!, duration: JustDuration.normal);

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

        Widget toastCard = RepaintBoundary(
          child: _JustToastWidget(
            entry: entry,
            enableDrag: enableDragDismiss,
            onDismiss: () => _dismissToast(entry),
          ),
        );

        if (pending.animationBuilder != null) {
          toastCard = pending.animationBuilder!(
            context,
            animController,
            toastCard,
          );
        }

        return _ToastPositionedWrapper(
          position: position,
          offset: offset,
          animation: animController,
          child: toastCard,
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
    if (!_activeToasts.contains(entry) || entry._dismissRequested) return;
    entry._dismissRequested = true;

    entry.timer.cancel();
    entry.animationController.reverse().then((_) {
      _cleanupToastEntry(entry);

      if (behavior == .queue && _queue.isNotEmpty) {
        _showToast(_queue.removeAt(0));
      }
    });
  }

  /// Synchronously removes and disposes [entry]'s overlay entry and (unless
  /// its animation controller is shared with another queued/active entry)
  /// disposes the controller too, then fires [entry.onDismissed] and
  /// repositions the remaining toasts.
  ///
  /// Guarded by [List.remove] returning `false` for an entry no longer in
  /// [_activeToasts], so this is safe to call more than once for the same
  /// [entry] — only the first call has any effect. This makes it safe to
  /// race against the animated cleanup scheduled by [_dismissToast].
  void _cleanupToastEntry(_ToastEntry entry) {
    entry.timer.cancel();
    if (!_activeToasts.remove(entry)) return;

    try {
      if (entry.overlayEntry.mounted) {
        entry.overlayEntry.remove();
      }
    } catch (_) {}
    try {
      entry.overlayEntry.dispose();
    } catch (_) {}

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
      try {
        entry.animationController.dispose();
      } catch (_) {}
    }

    if (entry.onDismissed != null) {
      entry.onDismissed!();
    }

    _updatePositions();
  }

  void _updatePositions() {
    if (_activeToasts.isEmpty) return;
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePositions();
      });
      return;
    }
    for (final toast in _activeToasts) {
      try {
        if (toast.overlayEntry.mounted) {
          toast.overlayEntry.markNeedsBuild();
        }
      } catch (_) {}
    }
  }

  @override
  void dismiss() {
    final targets = List<_ToastEntry>.from(_activeToasts);
    for (final toast in targets) {
      _dismissToast(toast);
    }
  }

  /// Immediately tears down every active toast without waiting for the exit
  /// animation to finish.
  ///
  /// Called when the hosting [JustToastScope] is being disposed — its
  /// [TickerProvider]/[OverlayState] are about to become unavailable, so any
  /// toast still visible must have its [OverlayEntry] and (if not shared)
  /// [AnimationController] released synchronously. Without this, entries
  /// inserted into an ancestor [Overlay] that outlives the scope (e.g. the
  /// app/root [Navigator]'s overlay) would stay inserted indefinitely,
  /// continuing to render stale content after the scope is gone. Pending
  /// queued toasts (not yet shown) are left untouched, since they hold no
  /// overlay/animation resources yet and can still be shown later if this
  /// controller is re-attached to a new scope.
  void forceDismissAll() {
    final targets = List<_ToastEntry>.from(_activeToasts);
    _activeToasts.clear();
    for (final entry in targets) {
      try {
        if (entry.overlayEntry.mounted) {
          entry.overlayEntry.remove();
        }
      } catch (_) {}
      try {
        entry.overlayEntry.dispose();
      } catch (_) {}

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
        try {
          entry.animationController.dispose();
        } catch (_) {}
      }

      if (entry.onDismissed != null) {
        try {
          entry.onDismissed!();
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    dismiss();
    _queue.clear();
  }
}

/// A wrapper widget that handles the slide/fade entrance and vertical staggering.
/// A wrapper widget that handles the slide/fade entrance and vertical staggering.
class const _ToastPositionedWrapper({
  required final ToastPosition position,
  required final double offset,
  required final Animation<double> animation,
  required final Widget child,
}) extends StatelessWidget {
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
/// The actual visual card of the Toast, supporting horizontal swipe-to-dismiss.
class const _JustToastWidget({
  required final _ToastEntry entry,
  required final bool enableDrag,
  required final VoidCallback onDismiss,
}) extends StatefulWidget {
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
      duration: JustDuration.fast,
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
        CurvedAnimation(
          parent: _swipeBackController,
          curve: JustCurves.default_,
        ),
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
    final defaultVariantBg = switch (widget.entry.variant) {
      .success => colors.success.withValues(alpha: 0.1),
      .error => colors.error.withValues(alpha: 0.1),
      .warning => colors.warning.withValues(alpha: 0.1),
      .info => colors.info.withValues(alpha: 0.08),
    };
    final defaultBg = Color.alphaBlend(defaultVariantBg, colors.card);
    final bgColor =
        entryStyle?.backgroundColor ??
        variantThemeStyle?.backgroundColor ??
        defaultBg;
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
/// Scope widget that binds a [JustToastController] and handles the Flutter context/ticker binding.
class const JustToastScope({
  super.key,

  /// If omitted, a default controller using [limit], [position], [behavior], and [enableDragDismiss] is automatically created.
  final JustToastController? controller,

  /// The maximum number of active/queued toasts. Defaults to 3.
  final int? limit = 3,

  /// The screen position where toasts are anchored. Defaults to [ToastPosition.bottomCenter].
  final ToastPosition position = .bottomCenter,

  /// The behavior mode (stacked or queue) for multiple toasts. Defaults to [ToastBehavior.stacked].
  final ToastBehavior behavior = .stacked,

  /// Whether to enable horizontal swipe-to-dismiss gesture. Defaults to true.
  final bool enableDragDismiss = true,

  /// The child subtree.
  required final Widget child,
}) extends StatefulWidget {
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
  JustToastController? _internalController;

  JustToastController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller == null) {
      _internalController = JustToastController(
        limit: widget.limit,
        position: widget.position,
        behavior: widget.behavior,
        enableDragDismiss: widget.enableDragDismiss,
      );
    } else {
      _internalController = null;
    }
    _effectiveController._vsync = this;
  }

  @override
  void didUpdateWidget(covariant JustToastScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final oldCtrl = oldWidget.controller ?? _internalController;
      oldCtrl?.forceDismissAll();
      oldCtrl?._vsync = null;
      oldCtrl?._overlayState = null;

      _initController();
    }
    _effectiveController._vsync = this;
    _effectiveController._overlayState = Overlay.maybeOf(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newOverlay = Overlay.maybeOf(context);
    if (_effectiveController._overlayState != null &&
        _effectiveController._overlayState != newOverlay) {
      _effectiveController.forceDismissAll();
    }
    _effectiveController._overlayState = newOverlay;
  }

  @override
  void dispose() {
    _effectiveController.forceDismissAll();
    _effectiveController._vsync = null;
    _effectiveController._overlayState = null;
    _internalController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _JustToastScopeInherited(
      controller: _effectiveController,
      child: widget.child,
    );
  }
}

class const _JustToastScopeInherited({
  required super.child,
  required final JustToastController controller,
}) extends InheritedWidget {
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

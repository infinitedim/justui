// justui-meta: registry=b93c3d76654b7958dc0268fa8283756035193cbf5a43f7d9b2cb76c813469557 local=55808f03f342dbf98b6844ca0efe8c7d527bc3c30b1eb5e4d1d6c2e7834c68de
import 'dart:async';

import 'package:material_ui/material_ui.dart' show Icons;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:sandbox/core/just_ui_core.dart';

import 'just_toast_style.dart';
import 'just_toast_theme.dart';
import 'just_toast_variants.dart';

/// Represents a single active toast entry in the overlay.
class _ToastEntry {
  final String id;
  final String message;
  final String? description;
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
    this.description,
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
  final String? description;
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
    this.description,
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
  BuildContext? _scopeContext;
  TickerProvider? _vsync;
  final List<_ToastEntry> _activeToasts = <_ToastEntry>[];
  final List<_ToastPending> _queue = <_ToastPending>[];

  Duration _resolveDuration() {
    final BuildContext? ctx = (_scopeContext?.mounted ?? false)
        ? _scopeContext
        : _overlayState?.context;
    if (ctx == null || !ctx.mounted) return JustDuration.normal;
    final JustMotionProfile? motion = JustThemeProvider.maybeOf(
      ctx,
      aspect: .animations,
    )?.theme.animations.resolve(ctx);
    final bool disableAnimations =
        motion?.normal == .zero ||
        (MediaQuery.maybeDisableAnimationsOf(ctx) ?? false);
    return disableAnimations ? .zero : (motion?.normal ?? JustDuration.normal);
  }

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
    String? description,
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

    final _ToastPending pending = _ToastPending(
      message: message,
      description: description,
      variant: variant,
      duration: duration,
      style: style,
      icon: icon,
      action: action,
      onDismissed: onDismissed,
      animationController: animationController,
      animationBuilder: animationBuilder,
    );

    final int? effectiveLimit = limit ?? this.limit;

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
        final List<_ToastEntry> activeVisible = _activeToasts
            .where((_ToastEntry t) => !t._dismissRequested)
            .toList();

        // 2. If active visible toasts reach limit, dismiss the oldest active one
        if (activeVisible.length >= effectiveLimit) {
          _dismissToast(activeVisible.first);
        }

        // 3. Immediately clean up any toasts that are already reversing/dismissing
        // if total entries exceed effectiveLimit to prevent overlay accumulation during rapid click spam
        while (_activeToasts.length >= effectiveLimit &&
            _activeToasts.any((_ToastEntry t) => t._dismissRequested)) {
          final _ToastEntry oldestDismissing = _activeToasts.firstWhere(
            (_ToastEntry t) => t._dismissRequested,
          );
          _cleanupToastEntry(oldestDismissing);
        }
      }
      _showToast(pending);
    }
  }

  void _showToast(_ToastPending pending) {
    final AnimationController animController =
        pending.animationController ??
        AnimationController(vsync: _vsync!, duration: _resolveDuration());

    late final _ToastEntry entry;
    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        final int index = _activeToasts.indexOf(entry);
        if (index == -1) return const SizedBox.shrink();

        final JustThemeData theme = JustThemeProvider.of(context).theme;
        final JustSpacingScheme spacing = theme.spacing;

        // Approximate toast height + spacing for stack offset calculations
        const double toastHeight = 56.0;
        final double toastSpacing = spacing.sm;
        final double offset =
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
      description: pending.description,
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
    final bool wasLocal =
        !_queue.any(
          (_ToastPending q) =>
              q.animationController == entry.animationController,
        ) &&
        _activeToasts
            .where(
              (_ToastEntry t) =>
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
    for (final _ToastEntry toast in _activeToasts) {
      try {
        if (toast.overlayEntry.mounted) {
          toast.overlayEntry.markNeedsBuild();
        }
      } catch (_) {}
    }
  }

  @override
  void dismiss() {
    final List<_ToastEntry> targets = List<_ToastEntry>.from(_activeToasts);
    for (final _ToastEntry toast in targets) {
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
    final List<_ToastEntry> targets = List<_ToastEntry>.from(_activeToasts);
    _activeToasts.clear();
    for (final _ToastEntry entry in targets) {
      entry.timer.cancel();
      try {
        if (entry.overlayEntry.mounted) {
          entry.overlayEntry.remove();
        }
      } catch (_) {}
      try {
        entry.overlayEntry.dispose();
      } catch (_) {}

      final bool wasLocal =
          !_queue.any(
            (_ToastPending q) =>
                q.animationController == entry.animationController,
          ) &&
          _activeToasts
              .where(
                (_ToastEntry t) =>
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
    final JustSpacingScheme spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final JustMotionProfile motion = JustThemeProvider.of(
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
    final bool isTop =
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

    final Tween<Offset> slideTween = isTop
        ? Tween<Offset>(begin: const Offset(0, -1), end: .zero)
        : Tween<Offset>(begin: const Offset(0, 1), end: .zero);

    final CurvedAnimation curvedAnimation = CurvedAnimation(
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
      duration: JustDuration.fast,
    );
    _swipeBackAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_swipeBackController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final JustMotionProfile? motion = JustThemeProvider.maybeOf(
      context,
      aspect: .animations,
    )?.theme.animations.resolve(context);
    final bool disableAnimations =
        motion?.fast == .zero ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    _swipeBackController.duration = disableAnimations
        ? .zero
        : (motion?.fast ?? JustDuration.fast);
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
      builder: (BuildContext context, Widget? child) {
        final double currentX = _swipeBackController.isAnimating
            ? _swipeBackAnimation.value
            : _dragX;
        final double opacity = (1.0 - (currentX.abs() / 300.0)).clamp(0.0, 1.0);
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
    return JustToastSurface(
      message: widget.entry.message,
      description: widget.entry.description,
      variant: widget.entry.variant,
      style: widget.entry.style,
      icon: widget.entry.icon,
      action: widget.entry.action,
      onDismiss: widget.onDismiss,
      showCloseButton: true,
      liveRegion: true,
    );
  }
}

class _ToastCloseButton extends StatefulWidget {
  final Color iconColor;
  final VoidCallback? onDismiss;

  const _ToastCloseButton({required this.iconColor, this.onDismiss});

  @override
  State<_ToastCloseButton> createState() => _ToastCloseButtonState();
}

class _ToastCloseButtonState extends State<_ToastCloseButton> {
  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      };

  bool _focused = false;

  void _handleFocusHighlight(bool show) {
    if (_focused != show) {
      setState(() => _focused = show);
    }
  }

  Decoration _focusDecoration(BuildContext context) {
    if (!_focused) return const BoxDecoration();
    final JustColorScheme colors = context.justColors;
    final JustPresetTokens presetTokens = context.justPresetTokens;
    final JustRadiusScheme radius = context.justRadius;
    final Color focusColor = presetTokens.showsDefaultBorder
        ? colors.textPrimary
        : colors.borderFocus;
    final double strokeWidth = presetTokens.showsDefaultBorder
        ? presetTokens.borderWidth
        : 2.0;
    return BoxDecoration(
      borderRadius: presetTokens.showsDefaultBorder ? .zero : .all(radius.sm),
      border: .all(color: focusColor, width: strokeWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onDismiss != null;
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      label: 'Dismiss',
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        shortcuts: _shortcuts,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent _) {
              widget.onDismiss?.call();
              return null;
            },
          ),
        },
        onShowFocusHighlight: _handleFocusHighlight,
        child: GestureDetector(
          behavior: .opaque,
          onTap: widget.onDismiss,
          child: DecoratedBox(
            decoration: _focusDecoration(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 24.0,
                minHeight: 24.0,
              ),
              child: Icon(Icons.close, color: widget.iconColor, size: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastVisuals {
  final Color bgColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final TextStyle descriptionTextStyle;
  final double minWidth;
  final double maxWidth;
  final List<BoxShadow> shadows;

  const _ToastVisuals({
    required this.bgColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.padding,
    required this.textStyle,
    required this.descriptionTextStyle,
    required this.minWidth,
    required this.maxWidth,
    required this.shadows,
  });
}

/// Standalone visual card surface for a toast notification.
class JustToastSurface extends StatelessWidget {
  /// Primary message text displayed in the toast.
  final String message;

  /// Optional secondary description text displayed below [message].
  final String? description;

  /// Semantic variant controlling default icon, tint, and theme lookup.
  final ToastVariant variant;

  /// Per-instance style overrides.
  final JustToastStyle? style;

  /// Custom text style applied to [description].
  final TextStyle? descriptionTextStyle;

  /// Optional leading icon widget. Defaults to a variant-appropriate icon.
  final Widget? icon;

  /// Optional trailing action widget replacing the default close button.
  final Widget? action;

  /// Callback invoked when the default close button is tapped.
  final VoidCallback? onDismiss;

  /// Whether to display the default close button when [action] is null.
  final bool showCloseButton;

  /// Whether to announce toast updates as a screen-reader live region.
  final bool liveRegion;

  const JustToastSurface({
    super.key,
    required this.message,
    this.description,
    this.variant = .info,
    this.style,
    this.descriptionTextStyle,
    this.icon,
    this.action,
    this.onDismiss,
    this.showCloseButton = true,
    this.liveRegion = false,
  });

  JustToastStyle? _variantStyle(JustToastTheme? globalTheme) {
    return switch (variant) {
      .info => globalTheme?.infoStyle,
      .success => globalTheme?.successStyle,
      .warning => globalTheme?.warningStyle,
      .error => globalTheme?.errorStyle,
    };
  }

  Color _defaultBackground(JustColorScheme colors) {
    final Color tint = switch (variant) {
      .success => colors.success.withValues(alpha: 0.1),
      .error => colors.error.withValues(alpha: 0.1),
      .warning => colors.warning.withValues(alpha: 0.1),
      .info => colors.info.withValues(alpha: 0.08),
    };
    return Color.alphaBlend(tint, colors.card);
  }

  _ToastVisuals _resolveVisuals(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustTypographyScheme typography = context.justTypo;
    final JustShadowScheme shadows = context.justShadows;
    final JustPresetTokens presetTokens = context.justPresetTokens;
    final JustToastStyle? themeStyle = _variantStyle(
      context.justThemeExtension<JustToastTheme>(),
    );
    final double maxWidth = style?.maxWidth ?? themeStyle?.maxWidth ?? 360.0;
    final double rawMin = style?.minWidth ?? themeStyle?.minWidth ?? 280.0;
    final Color fg =
        style?.foregroundColor ??
        themeStyle?.foregroundColor ??
        colors.textPrimary;
    return _ToastVisuals(
      bgColor:
          style?.backgroundColor ??
          themeStyle?.backgroundColor ??
          _defaultBackground(colors),
      borderColor:
          style?.borderColor ??
          themeStyle?.borderColor ??
          (presetTokens.showsDefaultBorder
              ? colors.textPrimary
              : colors.borderDefault),
      borderWidth:
          style?.borderWidth ??
          themeStyle?.borderWidth ??
          presetTokens.borderWidth,
      borderRadius:
          style?.borderRadius ?? themeStyle?.borderRadius ?? .all(radius.md),
      padding:
          style?.padding ??
          themeStyle?.padding ??
          .symmetric(horizontal: spacing.md, vertical: spacing.sm),
      textStyle:
          style?.textStyle ??
          themeStyle?.textStyle ??
          typography.bodySm.copyWith(color: fg),
      descriptionTextStyle:
          descriptionTextStyle ??
          typography.bodySm.copyWith(color: colors.textSecondary),
      minWidth: rawMin > maxWidth ? maxWidth : rawMin,
      maxWidth: maxWidth,
      shadows: style?.shadows ?? themeStyle?.shadows ?? shadows.md,
    );
  }

  Widget _defaultIcon(JustColorScheme colors) {
    return switch (variant) {
      .success => Icon(
        Icons.check_circle_outline,
        color: colors.success,
        size: 20.0,
      ),
      .warning => Icon(
        Icons.warning_amber_outlined,
        color: colors.warning,
        size: 20.0,
      ),
      .error => Icon(Icons.error_outline, color: colors.error, size: 20.0),
      .info => Icon(Icons.info_outline, color: colors.info, size: 20.0),
    };
  }

  Widget _buildBody(TextStyle textStyle, TextStyle descStyle) {
    if (description == null) {
      return Text(message, style: textStyle);
    }
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: <Widget>[
        Text(message, style: textStyle),
        const SizedBox(height: 2),
        Text(description!, style: descStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustSpacingScheme spacing = context.justSpacing;
    final _ToastVisuals visuals = _resolveVisuals(context);
    final Widget resolvedIcon = icon ?? _defaultIcon(colors);

    final Widget card = Container(
      constraints: BoxConstraints(
        minWidth: visuals.minWidth,
        maxWidth: visuals.maxWidth,
        minHeight: 48.0,
      ),
      decoration: BoxDecoration(
        color: visuals.bgColor,
        borderRadius: visuals.borderRadius,
        border: visuals.borderWidth > 0
            ? .fromBorderSide(
                BorderSide(
                  color: visuals.borderColor,
                  width: visuals.borderWidth,
                ),
              )
            : null,
        boxShadow: visuals.shadows,
      ),
      padding: visuals.padding,
      child: Row(
        mainAxisSize: .min,
        crossAxisAlignment: description != null ? .start : .center,
        children: <Widget>[
          resolvedIcon,
          SizedBox(width: spacing.sm),
          Expanded(
            child: _buildBody(visuals.textStyle, visuals.descriptionTextStyle),
          ),
          if (action != null) ...<Widget>[
            SizedBox(width: spacing.sm),
            action!,
          ] else if (showCloseButton) ...<Widget>[
            SizedBox(width: spacing.sm),
            _ToastCloseButton(
              iconColor: colors.textSecondary,
              onDismiss: onDismiss,
            ),
          ],
        ],
      ),
    );

    if (!liveRegion) return card;
    return Semantics(liveRegion: true, child: card);
  }
}

/// Scope widget that binds a [JustToastController] and handles the Flutter context/ticker binding.
/// Scope widget that binds a [JustToastController] and handles the Flutter context/ticker binding.
class JustToastScope extends StatefulWidget {
  /// If omitted, a default controller using [limit], [position], [behavior], and [enableDragDismiss] is automatically created.
  final JustToastController? controller;

  /// The maximum number of active/queued toasts. Defaults to 3.
  final int? limit;

  /// The screen position where toasts are anchored. Defaults to [ToastPosition.bottomCenter].
  final ToastPosition position;

  /// The behavior mode (stacked or queue) for multiple toasts. Defaults to [ToastBehavior.stacked].
  final ToastBehavior behavior;

  /// Whether to enable horizontal swipe-to-dismiss gesture. Defaults to true.
  final bool enableDragDismiss;

  /// The child subtree.
  final Widget child;

  const JustToastScope({
    super.key,
    this.controller,
    this.limit = 3,
    this.position = .bottomCenter,
    this.behavior = .stacked,
    this.enableDragDismiss = true,
    required this.child,
  });

  /// Retrieves the nearest [JustToastController] from the ancestor scope.
  static JustToastController of(BuildContext context) {
    final _JustToastScopeInherited? scope = context
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
      final JustToastController? oldCtrl =
          oldWidget.controller ?? _internalController;
      oldCtrl?.forceDismissAll();
      oldCtrl?._vsync = null;
      oldCtrl?._overlayState = null;
      oldCtrl?._scopeContext = null;

      _initController();
    }
    _effectiveController._vsync = this;
    _effectiveController._overlayState = Overlay.maybeOf(context);
    _effectiveController._scopeContext = context;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final OverlayState? newOverlay = Overlay.maybeOf(context);
    if (_effectiveController._overlayState != null &&
        _effectiveController._overlayState != newOverlay) {
      _effectiveController.forceDismissAll();
    }
    _effectiveController._overlayState = newOverlay;
    _effectiveController._scopeContext = context;
  }

  @override
  void dispose() {
    _effectiveController.forceDismissAll();
    _effectiveController._vsync = null;
    _effectiveController._overlayState = null;
    _effectiveController._scopeContext = null;
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

class _JustToastScopeInherited extends InheritedWidget {
  final JustToastController controller;

  const _JustToastScopeInherited({
    required super.child,
    required this.controller,
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

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart'
    show JustColorScheme, JustDuration, JustMotionProfile;

import '../../overlay/just_overlay_controller.dart';
import '../../theme/preset_tokens.dart';
import '../../theme/theme_data.dart';
import '../../theme/theme_data_material.dart';
import '../../theme/theme_provider.dart';
import 'just_dialog_style.dart';
import 'just_dialog_theme.dart';
import 'just_dialog_variants.dart';

/// Represents a single active dialog instance.
class _DialogInstance<T> {
  final String id;
  final Completer<T?> completer;
  final OverlayEntry barrierEntry;
  final OverlayEntry contentEntry;
  final AnimationController animationController;
  final bool isLocalController;

  /// Set as soon as a dismissal has been requested for this instance, so a
  /// second dismiss request for the same instance (e.g. a held-down Escape
  /// key delivering repeated key events) is a no-op instead of starting a
  /// second reverse animation.
  bool _dismissRequested = false;

  _DialogInstance({
    required this.id,
    required this.completer,
    required this.barrierEntry,
    required this.contentEntry,
    required this.animationController,
    required this.isLocalController,
  });
}

/// Imperative controller for managing dialogs.
class JustDialogController extends JustOverlayController {
  OverlayState? _overlayState;
  TickerProvider? _vsync;
  final List<_DialogInstance<dynamic>> _activeDialogs =
      <_DialogInstance<dynamic>>[];

  @override
  bool get isVisible => _activeDialogs.isNotEmpty;

  /// Shows a modal dialog and returns a [Future] that completes with the value
  /// passed when the dialog is dismissed or confirmed.
  Future<T?> show<T>({
    required Widget content,
    DialogPosition position = .center,
    bool barrierDismissable = true,
    Color? barrierColor,
    JustDialogStyle? style,
    AnimationController? animationController,
    JustOverlayAnimationBuilder? animationBuilder,
  }) {
    assert(
      _overlayState != null,
      'JustDialogController must be attached to a JustDialogScope before calling show()',
    );
    assert(
      _vsync != null,
      'JustDialogController must have a valid TickerProvider from JustDialogScope',
    );

    final Completer<T?> completer = Completer<T?>();
    final String id = DateTime.now().microsecondsSinceEpoch.toString();

    final bool isLocalController = animationController == null;
    final AnimationController animController =
        animationController ??
        AnimationController(vsync: _vsync!, duration: JustDuration.normal);

    late final _DialogInstance<T> instance;

    // 1. Barrier Entry
    final OverlayEntry barrierEntry = OverlayEntry(
      builder: (BuildContext context) {
        final JustThemeData theme = JustThemeProvider.of(context).theme;
        final JustColorScheme colors = theme.colors;
        final Color resolvedBarrierColor =
            style?.barrierColor ??
            barrierColor ??
            colors.overlay.withValues(alpha: 0.5);

        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animController,
            curve: Curves.linear,
          ),
          child: GestureDetector(
            onTap: barrierDismissable
                ? () => _dismissDialog(instance, null)
                : null,
            child: Container(color: resolvedBarrierColor),
          ),
        );
      },
    );

    // Save current focus to restore it later
    final FocusNode? previousFocus = FocusManager.instance.primaryFocus;

    // 2. Content Entry
    final OverlayEntry contentEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _JustDialogWidget(
          instance: instance,
          content: content,
          position: position,
          style: style,
          animationBuilder: animationBuilder,
          previousFocus: previousFocus,
          onDismiss: (dynamic val) => _dismissDialog(instance, val),
        );
      },
    );

    instance = _DialogInstance<T>(
      id: id,
      completer: completer,
      barrierEntry: barrierEntry,
      contentEntry: contentEntry,
      animationController: animController,
      isLocalController: isLocalController,
    );

    _activeDialogs.add(instance);
    _overlayState!.insert(barrierEntry);
    _overlayState!.insert(contentEntry);

    animController.forward();

    return completer.future;
  }

  void _dismissDialog(_DialogInstance<dynamic> instance, dynamic result) {
    if (!_activeDialogs.contains(instance) || instance._dismissRequested) {
      return;
    }
    instance._dismissRequested = true;

    instance.animationController.reverse().then((_) {
      _cleanupDialogInstance(instance, result);
    });
  }

  /// Synchronously removes and disposes [instance]'s overlay entries and
  /// (if locally-owned) its animation controller, then completes its result.
  ///
  /// Guarded by [List.remove] returning `false` for an instance no longer in
  /// [_activeDialogs], so this is safe to call more than once for the same
  /// [instance] — only the first call has any effect. This makes it safe to
  /// race against the animated cleanup scheduled by [_dismissDialog].
  void _cleanupDialogInstance(
    _DialogInstance<dynamic> instance,
    dynamic result,
  ) {
    if (!_activeDialogs.remove(instance)) return;

    instance.barrierEntry.remove();
    instance.barrierEntry.dispose();
    instance.contentEntry.remove();
    instance.contentEntry.dispose();

    if (instance.isLocalController) {
      instance.animationController.dispose();
    }

    if (!instance.completer.isCompleted) {
      instance.completer.complete(result);
    }
  }

  @override
  void dismiss() {
    final List<_DialogInstance<dynamic>> targets =
        List<_DialogInstance<dynamic>>.from(_activeDialogs);
    for (final _DialogInstance<dynamic> dialog in targets) {
      _dismissDialog(dialog, null);
    }
  }

  /// Immediately tears down every active dialog without waiting for the exit
  /// animation to finish.
  ///
  /// Called when the hosting [JustDialogScope] is being disposed — its
  /// [TickerProvider]/[OverlayState] are about to become unavailable, so any
  /// dialog still open must have its [OverlayEntry]s and locally-owned
  /// [AnimationController] released synchronously. Without this, entries
  /// inserted into an ancestor [Overlay] that outlives the scope (e.g. the
  /// app/root [Navigator]'s overlay) would stay inserted indefinitely,
  /// continuing to render stale content after the scope is gone.
  void forceDismissAll() {
    final List<_DialogInstance<dynamic>> targets =
        List<_DialogInstance<dynamic>>.from(_activeDialogs);
    for (final _DialogInstance<dynamic> instance in targets) {
      _cleanupDialogInstance(instance, null);
    }
  }

  @override
  void dispose() {
    dismiss();
  }
}

class const _ResolvedDialogStyle({
  required final Color backgroundColor,
  required final EdgeInsets padding,
  required final double maxWidth,
  required final double? maxHeight,
  required final List<BoxShadow> shadows,
  required final BorderRadius borderRadius,
  required final BoxBorder? border,
});

BoxBorder? _resolveDialogBorder(
  JustColorScheme colors,
  JustPresetTokens presetTokens,
  JustDialogStyle? style,
  JustDialogStyle? themeStyle,
) {
  final Color borderColor =
      style?.borderColor ??
      themeStyle?.borderColor ??
      (presetTokens.showsDefaultBorder
          ? colors.textPrimary
          : colors.borderDefault);
  final double borderWidth =
      style?.borderWidth ?? themeStyle?.borderWidth ?? presetTokens.borderWidth;
  return borderWidth > 0.0
      ? .fromBorderSide(BorderSide(color: borderColor, width: borderWidth))
      : null;
}

_ResolvedDialogStyle _resolveDialogStyle(
  BuildContext context,
  DialogPosition position,
  JustDialogStyle? style,
) {
  final JustColorScheme colors = context.justColors;
  final JustSpacingScheme spacing = context.justSpacing;
  final JustRadiusScheme radius = context.justRadius;
  final JustShadowScheme shadows = context.justShadows;
  final JustPresetTokens presetTokens = context.justPresetTokens;
  final JustDialogTheme? globalTheme = context
      .justThemeExtension<JustDialogTheme>();

  final JustDialogStyle? positionThemeStyle = switch (position) {
    .center => globalTheme?.centerStyle,
    .bottom => globalTheme?.bottomStyle,
    .top => globalTheme?.topStyle,
  };

  final BorderRadius defaultRadius = switch (position) {
    .center => .all(radius.lg),
    .bottom => .vertical(top: radius.lg),
    .top => .vertical(bottom: radius.lg),
  };

  return _ResolvedDialogStyle(
    backgroundColor:
        style?.backgroundColor ??
        positionThemeStyle?.backgroundColor ??
        colors.card,
    padding: style?.padding ?? positionThemeStyle?.padding ?? .all(spacing.lg),
    maxWidth:
        style?.maxWidth ??
        positionThemeStyle?.maxWidth ??
        (position == .center ? 480.0 : .infinity),
    maxHeight: style?.maxHeight ?? positionThemeStyle?.maxHeight,
    shadows:
        style?.shadows ??
        positionThemeStyle?.shadows ??
        presetTokens.resolveShadow(shadows, .lg, isPressed: false),
    borderRadius:
        style?.borderRadius ??
        positionThemeStyle?.borderRadius ??
        defaultRadius,
    border: _resolveDialogBorder(
      colors,
      presetTokens,
      style,
      positionThemeStyle,
    ),
  );
}

Alignment _dialogAlignment(DialogPosition position) => switch (position) {
  .center => .center,
  .bottom => .bottomCenter,
  .top => .topCenter,
};

/// Inline dialog surface container with JustUI card styling and preset tokens.
///
/// Renders the dialog card chrome (background, border, corner rounding, shadow,
/// padding, optional bottom grabber handle, and inherited text/icon themes)
/// without an overlay barrier, focus trap, or [JustDialogScope] dependency.
class const JustDialogSurface({
  super.key,

  /// The content rendered inside the dialog surface.
  required final Widget child,

  /// Placement variant controlling corner rounding, default max width, and
  /// whether a top grabber handle is shown when set to [.bottom].
  final DialogPosition position = .center,

  /// Per-instance style overrides.
  final JustDialogStyle? style,

  /// Whether to wrap the inner content in [SafeArea] for top/bottom placements.
  final bool useSafeArea = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _ResolvedDialogStyle resolved = _resolveDialogStyle(
      context,
      position,
      style,
    );
    final JustColorScheme colors = context.justColors;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustTypographyScheme typography = context.justTypo;

    final Widget body = Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: <Widget>[
        if (position == .bottom)
          Center(
            child: Container(
              width: 32.0,
              height: 4.0,
              margin: .only(bottom: spacing.md),
              decoration: BoxDecoration(
                color: colors.borderDefault,
                borderRadius: .all(radius.xs),
              ),
            ),
          ),
        DefaultTextStyle(
          style: typography.bodyMd.copyWith(color: colors.textPrimary),
          child: IconTheme.merge(
            data: IconThemeData(color: colors.textPrimary),
            child: child,
          ),
        ),
      ],
    );

    return Container(
      constraints: BoxConstraints(
        maxWidth: resolved.maxWidth,
        maxHeight: resolved.maxHeight ?? .infinity,
      ),
      decoration: BoxDecoration(
        color: resolved.backgroundColor,
        borderRadius: resolved.borderRadius,
        border: resolved.border,
        boxShadow: resolved.shadows,
      ),
      padding: resolved.padding,
      child: useSafeArea
          ? SafeArea(
              top: position == .top,
              bottom: position == .bottom,
              child: body,
            )
          : body,
    );
  }
}

/// The internal widget for rendering the dialog content with focus trapping and keyboard shortcuts.
class const _JustDialogWidget({
  required final _DialogInstance<dynamic> instance,
  required final Widget content,
  required final DialogPosition position,
  final JustDialogStyle? style,
  final JustOverlayAnimationBuilder? animationBuilder,
  final FocusNode? previousFocus,
  required final ValueChanged<dynamic> onDismiss,
}) extends StatefulWidget {
  @override
  State<_JustDialogWidget> createState() => _JustDialogWidgetState();
}

class _JustDialogWidgetState extends State<_JustDialogWidget> {
  late final FocusScopeNode _scopeNode;

  @override
  void initState() {
    super.initState();
    _scopeNode = FocusScopeNode(canRequestFocus: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scopeNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _scopeNode.dispose();
    // Restore focus asynchronously after the frame to prevent layout/focus conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.previousFocus?.requestFocus();
    });
    super.dispose();
  }

  Widget _buildAnimatedCard(
    BuildContext context,
    JustMotionProfile motion,
    Widget card,
  ) {
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!(
        context,
        widget.instance.animationController,
        card,
      );
    }
    final CurvedAnimation curved = CurvedAnimation(
      parent: widget.instance.animationController,
      curve: motion.enter,
      reverseCurve: motion.exit,
    );
    return switch (widget.position) {
      .center => FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
          child: card,
        ),
      ),
      .bottom => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: .zero,
        ).animate(curved),
        child: card,
      ),
      .top => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: .zero,
        ).animate(curved),
        child: card,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final JustSpacingScheme spacing = context.justSpacing;
    final JustMotionProfile motion = context.justMotion;
    final Widget card = JustDialogSurface(
      position: widget.position,
      style: widget.style,
      useSafeArea: true,
      child: widget.content,
    );

    return RepaintBoundary(
      child: FocusScope(
        node: _scopeNode,
        autofocus: true,
        canRequestFocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onDismiss(null);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: <Widget>[
            Align(
              alignment: _dialogAlignment(widget.position),
              child: Padding(
                padding: widget.position == .center ? .all(spacing.lg) : .zero,
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  label: 'Dialog',
                  child: _buildAnimatedCard(context, motion, card),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scope widget that binds a [JustDialogController] and handles the Flutter context/ticker binding.
/// Scope widget that binds a [JustDialogController] and handles the Flutter context/ticker binding.
class const JustDialogScope({
  super.key,

  /// The controller that manages the dialog overlay.
  required final JustDialogController controller,

  /// The child subtree.
  required final Widget child,
}) extends StatefulWidget {
  /// Retrieves the nearest [JustDialogController] from the ancestor scope.
  static JustDialogController of(BuildContext context) {
    final _JustDialogScopeInherited? scope = context
        .dependOnInheritedWidgetOfExactType<_JustDialogScopeInherited>();
    assert(scope != null, 'No JustDialogScope found in context');
    return scope!.controller;
  }

  @override
  State<JustDialogScope> createState() => _JustDialogScopeState();
}

class _JustDialogScopeState extends State<JustDialogScope>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller._vsync = this;
  }

  @override
  void didUpdateWidget(covariant JustDialogScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.forceDismissAll();
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
    widget.controller.forceDismissAll();
    widget.controller._vsync = null;
    widget.controller._overlayState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _JustDialogScopeInherited(
      controller: widget.controller,
      child: widget.child,
    );
  }
}

class const _JustDialogScopeInherited({
  required super.child,
  required final JustDialogController controller,
}) extends InheritedWidget {
  @override
  bool updateShouldNotify(_JustDialogScopeInherited oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Context extensions to easily access dialog functionality.
extension JustDialogContextExtension on BuildContext {
  /// Retrieves the nearest [JustDialogController] for showing modal dialogs.
  JustDialogController get justDialog => JustDialogScope.of(this);
}

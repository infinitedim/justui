import 'dart:async';

import 'package:flutter/material.dart' show Theme, showGeneralDialog;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../overlay/just_overlay_controller.dart';
import '../../theme/theme_provider.dart';
import 'just_sheet_style.dart';
import 'just_sheet_theme.dart';
import 'just_sheet_variants.dart';

/// Represents an active sheet instance.
class _SheetInstance<T> {
  final String id;
  final Completer<T?> completer;
  final OverlayEntry barrierEntry;
  final OverlayEntry contentEntry;
  final AnimationController animationController;
  final bool isLocalController;

  /// Set as soon as a dismissal has been requested for this instance, so a
  /// second dismiss request for the same instance (e.g. a held-down Escape
  /// key delivering repeated key events, or a drag-to-dismiss racing the
  /// Escape handler) is a no-op instead of starting a second reverse
  /// animation.
  bool _dismissRequested = false;

  _SheetInstance({
    required this.id,
    required this.completer,
    required this.barrierEntry,
    required this.contentEntry,
    required this.animationController,
    required this.isLocalController,
  });
}

/// Imperative controller for managing slide-in sheets.
class JustSheetController extends JustOverlayController {
  OverlayState? _overlayState;
  TickerProvider? _vsync;
  final List<_SheetInstance<dynamic>> _activeSheets = [];

  @override
  bool get isVisible => _activeSheets.isNotEmpty;

  /// Shows a slide-in sheet and returns a [Future] that completes with the value
  /// passed when the sheet is dismissed or confirmed.
  Future<T?> show<T>({
    required Widget content,
    SheetDirection direction = .bottom,
    bool barrierDismissable = true,
    Color? barrierColor,
    double? size,
    double? maxSize,
    bool draggable = false,
    JustSheetStyle? style,
    AnimationController? animationController,
    JustOverlayAnimationBuilder? animationBuilder,
  }) {
    assert(
      _overlayState != null,
      'JustSheetController must be attached to a JustSheetScope before calling show()',
    );
    assert(
      _vsync != null,
      'JustSheetController must have a valid TickerProvider from JustSheetScope',
    );

    final completer = Completer<T?>();
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final isLocalController = animationController == null;
    final animController =
        animationController ??
        AnimationController(
          vsync: _vsync!,
          duration: const Duration(milliseconds: 300),
        );

    late final _SheetInstance<T> instance;

    // 1. Barrier Entry
    final barrierEntry = OverlayEntry(
      builder: (context) {
        final theme = JustThemeProvider.of(context).theme;
        final colors = theme.colors;
        final resolvedBarrierColor =
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
                ? () => _dismissSheet(instance, null)
                : null,
            child: Container(color: resolvedBarrierColor),
          ),
        );
      },
    );

    final previousFocus = FocusManager.instance.primaryFocus;

    // 2. Content Entry
    final contentEntry = OverlayEntry(
      builder: (context) {
        return _JustSheetWidget(
          instance: instance,
          content: content,
          direction: direction,
          size: size,
          maxSize: maxSize,
          draggable: draggable,
          style: style,
          animationBuilder: animationBuilder,
          previousFocus: previousFocus,
          onDismiss: (val) => _dismissSheet(instance, val),
        );
      },
    );

    instance = _SheetInstance<T>(
      id: id,
      completer: completer,
      barrierEntry: barrierEntry,
      contentEntry: contentEntry,
      animationController: animController,
      isLocalController: isLocalController,
    );

    _activeSheets.add(instance);
    _overlayState!.insert(barrierEntry);
    _overlayState!.insert(contentEntry);

    animController.forward();

    return completer.future;
  }

  void _dismissSheet(_SheetInstance<dynamic> instance, dynamic result) {
    if (!_activeSheets.contains(instance) || instance._dismissRequested) {
      return;
    }
    instance._dismissRequested = true;

    instance.animationController.reverse().then((_) {
      _cleanupSheetInstance(instance, result);
    });
  }

  /// Synchronously removes and disposes [instance]'s overlay entries and
  /// (if locally-owned) its animation controller, then completes its result.
  ///
  /// Guarded by [List.remove] returning `false` for an instance no longer in
  /// [_activeSheets], so this is safe to call more than once for the same
  /// [instance] — only the first call has any effect. This makes it safe to
  /// race against the animated cleanup scheduled by [_dismissSheet].
  void _cleanupSheetInstance(_SheetInstance<dynamic> instance, dynamic result) {
    if (!_activeSheets.remove(instance)) return;

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
    final targets = List<_SheetInstance<dynamic>>.from(_activeSheets);
    for (final sheet in targets) {
      _dismissSheet(sheet, null);
    }
  }

  /// Immediately tears down every active sheet without waiting for the exit
  /// animation to finish.
  ///
  /// Called when the hosting [JustSheetScope] is being disposed — its
  /// [TickerProvider]/[OverlayState] are about to become unavailable, so any
  /// sheet still open must have its [OverlayEntry]s and locally-owned
  /// [AnimationController] released synchronously. Without this, entries
  /// inserted into an ancestor [Overlay] that outlives the scope (e.g. the
  /// app/root [Navigator]'s overlay) would stay inserted indefinitely,
  /// continuing to render stale content after the scope is gone.
  void forceDismissAll() {
    final targets = List<_SheetInstance<dynamic>>.from(_activeSheets);
    for (final instance in targets) {
      _cleanupSheetInstance(instance, null);
    }
  }

  @override
  void dispose() {
    dismiss();
  }
}

/// The internal widget for rendering the sheet content with drag-to-dismiss and focus trapping.
/// The internal widget for rendering the sheet content with drag-to-dismiss and focus trapping.
class const _JustSheetWidget({
  required final _SheetInstance<dynamic> instance,
  required final Widget content,
  required final SheetDirection direction,
  final double? size,
  final double? maxSize,
  required final bool draggable,
  final JustSheetStyle? style,
  final JustOverlayAnimationBuilder? animationBuilder,
  final FocusNode? previousFocus,
  required final ValueChanged<dynamic> onDismiss,
}) extends StatefulWidget {
  @override
  State<_JustSheetWidget> createState() => _JustSheetWidgetState();
}

class _JustSheetWidgetState extends State<_JustSheetWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.previousFocus?.requestFocus();
    });
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.draggable) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final delta = details.primaryDelta! / screenHeight;

    // For bottom: dragging down (positive delta) reduces animation value.
    // For top: dragging up (negative delta) reduces animation value.
    if (widget.direction == .bottom) {
      widget.instance.animationController.value =
          (widget.instance.animationController.value - delta).clamp(0.0, 1.0);
    } else if (widget.direction == .top) {
      widget.instance.animationController.value =
          (widget.instance.animationController.value + delta).clamp(0.0, 1.0);
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.draggable) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final delta = details.primaryDelta! / screenWidth;

    // For right: dragging right (positive delta) reduces animation value.
    // For left: dragging left (negative delta) reduces animation value.
    if (widget.direction == .right) {
      widget.instance.animationController.value =
          (widget.instance.animationController.value - delta).clamp(0.0, 1.0);
    } else if (widget.direction == .left) {
      widget.instance.animationController.value =
          (widget.instance.animationController.value + delta).clamp(0.0, 1.0);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.draggable) return;
    if (widget.instance.animationController.value < 0.5) {
      widget.onDismiss(null);
    } else {
      widget.instance.animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final radius = theme.radius;
    final shadows = theme.shadows;
    final motion = theme.animations.resolve(context);
    final typography = theme.typography;

    final globalTheme = Theme.of(context).extension<JustSheetTheme>();

    JustSheetStyle? directionThemeStyle;
    switch (widget.direction) {
      case .bottom:
        directionThemeStyle = globalTheme?.bottomStyle;
        break;
      case .top:
        directionThemeStyle = globalTheme?.topStyle;
        break;
      case .left:
        directionThemeStyle = globalTheme?.leftStyle;
        break;
      case .right:
        directionThemeStyle = globalTheme?.rightStyle;
        break;
    }

    final entryStyle = widget.style;

    // Resolve styles
    final bgColor =
        entryStyle?.backgroundColor ??
        directionThemeStyle?.backgroundColor ??
        colors.card;
    final padding =
        entryStyle?.padding ?? directionThemeStyle?.padding ?? .all(spacing.lg);
    final handleColor =
        entryStyle?.handleColor ??
        directionThemeStyle?.handleColor ??
        colors.borderDefault;
    final sheetShadows =
        entryStyle?.shadows ?? directionThemeStyle?.shadows ?? shadows.lg;

    final BorderRadius resolvedRadius;
    switch (widget.direction) {
      case .bottom:
        resolvedRadius =
            entryStyle?.borderRadius ??
            directionThemeStyle?.borderRadius ??
            .vertical(top: radius.lg);
        break;
      case .top:
        resolvedRadius =
            entryStyle?.borderRadius ??
            directionThemeStyle?.borderRadius ??
            .vertical(bottom: radius.lg);
        break;
      case .left:
        resolvedRadius =
            entryStyle?.borderRadius ??
            directionThemeStyle?.borderRadius ??
            .horizontal(right: radius.lg);
        break;
      case .right:
        resolvedRadius =
            entryStyle?.borderRadius ??
            directionThemeStyle?.borderRadius ??
            .horizontal(left: radius.lg);
        break;
    }

    final presetTokens = theme.presetTokens;
    final borderSide = BorderSide(
      color: presetTokens.showsDefaultBorder
          ? colors.textPrimary
          : colors.borderDefault,
      width: presetTokens.borderWidth,
    );

    // Calculate layout sizing based on direction and screen dimensions
    final screenSize = MediaQuery.of(context).size;

    double? width;
    double? height;
    Alignment alignment;

    switch (widget.direction) {
      case .bottom:
        height = widget.size != null ? screenSize.height * widget.size! : null;
        if (widget.maxSize != null && height != null) {
          height = height.clamp(0.0, screenSize.height * widget.maxSize!);
        }
        width = .infinity;
        alignment = .bottomCenter;
        break;
      case .top:
        height = widget.size != null ? screenSize.height * widget.size! : null;
        if (widget.maxSize != null && height != null) {
          height = height.clamp(0.0, screenSize.height * widget.maxSize!);
        }
        width = .infinity;
        alignment = .topCenter;
        break;
      case .left:
        width = widget.size != null ? screenSize.width * widget.size! : null;
        if (widget.maxSize != null && width != null) {
          width = width.clamp(0.0, screenSize.width * widget.maxSize!);
        }
        height = .infinity;
        alignment = .centerLeft;
        break;
      case .right:
        width = widget.size != null ? screenSize.width * widget.size! : null;
        if (widget.maxSize != null && width != null) {
          width = width.clamp(0.0, screenSize.width * widget.maxSize!);
        }
        height = .infinity;
        alignment = .centerRight;
        break;
    }

    // Drag handle bar
    final isVertical = widget.direction == .bottom || widget.direction == .top;

    // Keyboard inset awareness for bottom sheets
    final bottomInset = widget.direction == .bottom
        ? MediaQuery.of(context).viewInsets.bottom
        : 0.0;

    final MainAxisSize mainAxisSize = widget.size != null ? .max : .min;

    Widget card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: resolvedRadius,
        border: .fromBorderSide(borderSide),
        boxShadow: theme.resolveShadows(sheetShadows, isPressed: false),
      ),
      padding: padding,
      child: SafeArea(
        top: widget.direction == .top,
        bottom: widget.direction == .bottom,
        left: widget.direction == .left,
        right: widget.direction == .right,
        child: Column(
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: .stretch,
          children: [
            if (widget.draggable && isVertical) ...[
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  margin: .only(bottom: spacing.md),
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: .all(radius.xs),
                  ),
                ),
              ),
            ],
            if (widget.size != null)
              Expanded(
                child: DefaultTextStyle(
                  style: typography.bodyMd.copyWith(color: colors.textPrimary),
                  child: IconTheme.merge(
                    data: IconThemeData(color: colors.textPrimary),
                    child: widget.content,
                  ),
                ),
              )
            else
              DefaultTextStyle(
                style: typography.bodyMd.copyWith(color: colors.textPrimary),
                child: IconTheme.merge(
                  data: IconThemeData(color: colors.textPrimary),
                  child: widget.content,
                ),
              ),
            // Reserve space for keyboard when visible on bottom sheets
            if (bottomInset > 0) SizedBox(height: bottomInset),
          ],
        ),
      ),
    );

    // Apply drag gesture detector
    if (widget.draggable) {
      card = GestureDetector(
        onVerticalDragUpdate: isVertical ? _onVerticalDragUpdate : null,
        onVerticalDragEnd: isVertical ? _onDragEnd : null,
        onHorizontalDragUpdate: !isVertical ? _onHorizontalDragUpdate : null,
        onHorizontalDragEnd: !isVertical ? _onDragEnd : null,
        child: card,
      );
    }

    // Apply animation
    final curvedAnimation = CurvedAnimation(
      parent: widget.instance.animationController,
      curve: motion.enter,
      reverseCurve: motion.exit,
    );

    Widget animatedChild;
    if (widget.animationBuilder != null) {
      animatedChild = widget.animationBuilder!(
        context,
        widget.instance.animationController,
        card,
      );
    } else {
      Offset beginOffset;
      switch (widget.direction) {
        case .bottom:
          beginOffset = const Offset(0, 1);
          break;
        case .top:
          beginOffset = const Offset(0, -1);
          break;
        case .left:
          beginOffset = const Offset(-1, 0);
          break;
        case .right:
          beginOffset = const Offset(1, 0);
          break;
      }

      animatedChild = SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: .zero,
        ).animate(curvedAnimation),
        child: card,
      );
    }

    return RepaintBoundary(
      child: FocusScope(
        autofocus: true,
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent && event.logicalKey == .escape) {
              widget.onDismiss(null);
            }
          },
          child: Stack(
            children: [
              Align(
                alignment: alignment,
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  label: 'Sheet',
                  child: animatedChild,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scope widget that binds a [JustSheetController] and handles the Flutter context/ticker binding.
/// Scope widget that binds a [JustSheetController] and handles the Flutter context/ticker binding.
class const JustSheetScope({
  super.key,

  /// The controller that manages the sheet overlay.
  required final JustSheetController controller,

  /// The child subtree.
  required final Widget child,
}) extends StatefulWidget {
  /// Retrieves the nearest [JustSheetController] from the ancestor scope.
  static JustSheetController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_JustSheetScopeInherited>();
    assert(scope != null, 'No JustSheetScope found in context');
    return scope!.controller;
  }

  /// Retrieves the nearest [JustSheetController] from the ancestor scope if available.
  static JustSheetController? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_JustSheetScopeInherited>();
    return scope?.controller;
  }

  @override
  State<JustSheetScope> createState() => _JustSheetScopeState();
}

class _JustSheetScopeState extends State<JustSheetScope>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller._vsync = this;
  }

  @override
  void didUpdateWidget(covariant JustSheetScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      // The old controller is being detached from this scope, so it must
      // release any sheets it still has open the same way dispose() does.
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
    // Force-clear any sheets still open before this scope's TickerProvider
    // and OverlayState become unavailable below, otherwise their
    // OverlayEntry(s) would be orphaned in the ancestor Overlay indefinitely.
    widget.controller.forceDismissAll();
    widget.controller._vsync = null;
    widget.controller._overlayState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _JustSheetScopeInherited(
      controller: widget.controller,
      child: widget.child,
    );
  }
}

class const _JustSheetScopeInherited({
  required super.child,
  required final JustSheetController controller,
}) extends InheritedWidget {
  @override
  bool updateShouldNotify(_JustSheetScopeInherited oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Context extensions to easily access sheet functionality.
extension JustSheetContextExtension on BuildContext {
  /// Retrieves the nearest [JustSheetController] for showing sheets.
  JustSheetController get justSheet => JustSheetScope.of(this);
}

/// Shows a modal bottom sheet with JustUI styling and physics-based enter/exit animations.
///
/// If a [JustSheetScope] is present in [context], it delegates to it. Otherwise,
/// it presents a modal sheet route matching the exact visual and animation specs of [JustSheet].
Future<T?> showJustBottomSheet<T>({
  required BuildContext context,
  required Widget content,
  SheetDirection direction = .bottom,
  bool barrierDismissable = true,
  Color? barrierColor,
  double? size,
  double? maxSize,
  bool draggable = true,
  JustSheetStyle? style,
}) {
  final scope = JustSheetScope.maybeOf(context);
  if (scope != null) {
    return scope.show<T>(
      content: content,
      direction: direction,
      barrierDismissable: barrierDismissable,
      barrierColor: barrierColor,
      size: size,
      maxSize: maxSize,
      draggable: draggable,
      style: style,
    );
  }

  final themeState = JustThemeProvider.maybeOf(context);
  final theme = themeState?.theme ?? JustThemeProvider.of(context).theme;
  final colors = theme.colors;
  final radius = theme.radius;
  final spacing = theme.spacing;
  final shadows = theme.shadows;
  final presetTokens = theme.presetTokens;

  final borderSide = BorderSide(
    color: presetTokens.showsDefaultBorder
        ? colors.textPrimary
        : colors.borderDefault,
    width: presetTokens.borderWidth,
  );

  final isVertical = direction == .bottom || direction == .top;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissable,
    useRootNavigator: false,
    barrierLabel: 'Dismiss',
    transitionDuration: const Duration(milliseconds: 300),
    barrierColor:
        style?.barrierColor ??
        barrierColor ??
        colors.overlay.withValues(alpha: 0.5),
    pageBuilder: (context, animation, secondaryAnimation) {
      Alignment alignment;
      switch (direction) {
        case .bottom:
          alignment = .bottomCenter;
          break;
        case .top:
          alignment = .topCenter;
          break;
        case .left:
          alignment = .centerLeft;
          break;
        case .right:
          alignment = .centerRight;
          break;
      }

      return Align(
        alignment: alignment,
        child: Container(
          width: .infinity,
          decoration: BoxDecoration(
            color: style?.backgroundColor ?? colors.card,
            borderRadius: style?.borderRadius ?? .vertical(top: radius.lg),
            border: .fromBorderSide(borderSide),
            boxShadow: theme.resolveShadows(
              style?.shadows ?? shadows.lg,
              isPressed: false,
            ),
          ),
          padding: style?.padding ?? .all(spacing.lg),
          child: SafeArea(
            top: direction == .top,
            bottom: direction == .bottom,
            left: direction == .left,
            right: direction == .right,
            child: Column(
              mainAxisSize: size != null ? .max : .min,
              crossAxisAlignment: .stretch,
              children: [
                if (draggable && isVertical)
                  Center(
                    child: Container(
                      width: 36.0,
                      height: 4.0,
                      margin: .only(bottom: spacing.md),
                      decoration: BoxDecoration(
                        color: style?.handleColor ?? colors.borderDefault,
                        borderRadius: .all(radius.xs),
                      ),
                    ),
                  ),
                if (size != null) Expanded(child: content) else content,
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      Offset beginOffset;
      switch (direction) {
        case .bottom:
          beginOffset = const Offset(0, 1.0);
          break;
        case .top:
          beginOffset = const Offset(0, -1.0);
          break;
        case .left:
          beginOffset = const Offset(-1.0, 0);
          break;
        case .right:
          beginOffset = const Offset(1.0, 0);
          break;
      }

      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: theme.animations.enter,
        reverseCurve: theme.animations.exit,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: .zero,
        ).animate(curvedAnimation),
        child: child,
      );
    },
  );
}

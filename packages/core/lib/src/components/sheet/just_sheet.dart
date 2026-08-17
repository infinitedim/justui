import 'dart:async';

import 'package:flutter/material.dart' show Theme;
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
class _JustSheetWidget extends StatefulWidget {
  final _SheetInstance<dynamic> instance;
  final Widget content;
  final SheetDirection direction;
  final double? size;
  final double? maxSize;
  final bool draggable;
  final JustSheetStyle? style;
  final JustOverlayAnimationBuilder? animationBuilder;
  final FocusNode? previousFocus;
  final ValueChanged<dynamic> onDismiss;

  const _JustSheetWidget({
    required this.instance,
    required this.content,
    required this.direction,
    this.size,
    this.maxSize,
    required this.draggable,
    this.style,
    this.animationBuilder,
    this.previousFocus,
    required this.onDismiss,
  });

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
    const double defaultSizeFraction = 0.4;
    final double fraction = widget.size ?? defaultSizeFraction;

    double? width;
    double? height;
    Alignment alignment;

    switch (widget.direction) {
      case .bottom:
        height = screenSize.height * fraction;
        if (widget.maxSize != null) {
          height = height.clamp(0.0, screenSize.height * widget.maxSize!);
        }
        width = .infinity;
        alignment = .bottomCenter;
        break;
      case .top:
        height = screenSize.height * fraction;
        if (widget.maxSize != null) {
          height = height.clamp(0.0, screenSize.height * widget.maxSize!);
        }
        width = .infinity;
        alignment = .topCenter;
        break;
      case .left:
        width = screenSize.width * fraction;
        if (widget.maxSize != null) {
          width = width.clamp(0.0, screenSize.width * widget.maxSize!);
        }
        height = .infinity;
        alignment = .centerLeft;
        break;
      case .right:
        width = screenSize.width * fraction;
        if (widget.maxSize != null) {
          width = width.clamp(0.0, screenSize.width * widget.maxSize!);
        }
        height = .infinity;
        alignment = .centerRight;
        break;
    }

    // Drag handle bar
    final isVertical = widget.direction == .bottom || widget.direction == .top;

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
          mainAxisSize: .max,
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
            Expanded(child: widget.content),
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
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
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
class JustSheetScope extends StatefulWidget {
  /// The controller that manages the sheet overlay.
  final JustSheetController controller;

  /// The child subtree.
  final Widget child;

  /// Creates a [JustSheetScope].
  const JustSheetScope({
    super.key,
    required this.controller,
    required this.child,
  });

  /// Retrieves the nearest [JustSheetController] from the ancestor scope.
  static JustSheetController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_JustSheetScopeInherited>();
    assert(scope != null, 'No JustSheetScope found in context');
    return scope!.controller;
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

class _JustSheetScopeInherited extends InheritedWidget {
  final JustSheetController controller;

  const _JustSheetScopeInherited({
    required this.controller,
    required super.child,
  });

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

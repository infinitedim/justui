// justui-meta: registry=f8b2e23d61501bdff2cfa2a6368dc3a423299d707e6e60024f05e38bb15c5b1a local=f37f0d3bb8f07dbb388d246ac1513eb7d17aa8fd9b62eff06d18c091d3c68d62
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sandbox/core/just_ui_core.dart';

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
  final List<_SheetInstance<dynamic>> _activeSheets =
      <_SheetInstance<dynamic>>[];

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

    final Completer<T?> completer = Completer<T?>();
    final String id = DateTime.now().microsecondsSinceEpoch.toString();

    final bool isLocalController = animationController == null;
    final AnimationController animController =
        animationController ??
        AnimationController(
          vsync: _vsync!,
          duration: const Duration(milliseconds: 300),
        );

    late final _SheetInstance<T> instance;

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
                ? () => _dismissSheet(instance, null)
                : null,
            child: Container(color: resolvedBarrierColor),
          ),
        );
      },
    );

    final FocusNode? previousFocus = FocusManager.instance.primaryFocus;

    // 2. Content Entry
    final OverlayEntry contentEntry = OverlayEntry(
      builder: (BuildContext context) {
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
          onDismiss: (dynamic val) => _dismissSheet(instance, val),
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
    final List<_SheetInstance<dynamic>> targets =
        List<_SheetInstance<dynamic>>.from(_activeSheets);
    for (final _SheetInstance<dynamic> sheet in targets) {
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
    final List<_SheetInstance<dynamic>> targets =
        List<_SheetInstance<dynamic>>.from(_activeSheets);
    for (final _SheetInstance<dynamic> instance in targets) {
      _cleanupSheetInstance(instance, null);
    }
  }

  @override
  void dispose() {
    dismiss();
  }
}

class _ResolvedSheetStyle {
  final Color backgroundColor;
  final EdgeInsets padding;
  final Color handleColor;
  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;
  final BoxBorder? border;

  const _ResolvedSheetStyle({
    required this.backgroundColor,
    required this.padding,
    required this.handleColor,
    required this.shadows,
    required this.borderRadius,
    required this.border,
  });
}

BoxBorder? _resolveSheetBorder(
  JustColorScheme colors,
  JustPresetTokens presetTokens,
  JustSheetStyle? style,
  JustSheetStyle? themeStyle,
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

_ResolvedSheetStyle _resolveSheetStyle(
  BuildContext context,
  SheetDirection direction,
  JustSheetStyle? style,
) {
  final JustColorScheme colors = context.justColors;
  final JustSpacingScheme spacing = context.justSpacing;
  final JustRadiusScheme radius = context.justRadius;
  final JustShadowScheme shadows = context.justShadows;
  final JustPresetTokens presetTokens = context.justPresetTokens;
  final JustSheetTheme? globalTheme = context
      .justThemeExtension<JustSheetTheme>();

  final JustSheetStyle? directionThemeStyle = switch (direction) {
    .bottom => globalTheme?.bottomStyle,
    .top => globalTheme?.topStyle,
    .left => globalTheme?.leftStyle,
    .right => globalTheme?.rightStyle,
  };

  final BorderRadius defaultRadius = switch (direction) {
    .bottom => .vertical(top: radius.lg),
    .top => .vertical(bottom: radius.lg),
    .left => .horizontal(right: radius.lg),
    .right => .horizontal(left: radius.lg),
  };

  return _ResolvedSheetStyle(
    backgroundColor:
        style?.backgroundColor ??
        directionThemeStyle?.backgroundColor ??
        colors.card,
    padding: style?.padding ?? directionThemeStyle?.padding ?? .all(spacing.lg),
    handleColor:
        style?.handleColor ??
        directionThemeStyle?.handleColor ??
        colors.borderDefault,
    shadows:
        style?.shadows ??
        directionThemeStyle?.shadows ??
        presetTokens.resolveShadow(shadows, .lg, isPressed: false),
    borderRadius:
        style?.borderRadius ??
        directionThemeStyle?.borderRadius ??
        defaultRadius,
    border: _resolveSheetBorder(
      colors,
      presetTokens,
      style,
      directionThemeStyle,
    ),
  );
}

Alignment _sheetAlignment(SheetDirection direction) => switch (direction) {
  .bottom => .bottomCenter,
  .top => .topCenter,
  .left => .centerLeft,
  .right => .centerRight,
};

Offset _sheetSlideBeginOffset(SheetDirection direction) => switch (direction) {
  .bottom => const Offset(0, 1.0),
  .top => const Offset(0, -1.0),
  .left => const Offset(-1.0, 0),
  .right => const Offset(1.0, 0),
};

/// Inline sheet surface container with JustUI card styling and preset tokens.
///
/// Renders the sheet card chrome (background, directional corner rounding,
/// border, shadow, padding, optional drag grabber handle, and inherited
/// text/icon themes) without an overlay barrier, drag gesture detector, focus
/// trap, or [JustSheetScope] dependency.
class JustSheetSurface extends StatelessWidget {
  /// The content rendered inside the sheet surface.
  final Widget child;

  /// Edge direction controlling corner rounding and axis sizing.
  final SheetDirection direction;

  /// Whether to show the drag grabber bar on vertical sheets.
  final bool showHandle;

  /// Optional fractional viewport size along the sheet's primary axis (0.0 to 1.0).
  final double? size;

  /// Optional maximum fractional viewport size along the sheet's primary axis.
  final double? maxSize;

  /// Extra bottom spacing reserved inside bottom sheets (e.g. keyboard inset).
  final double? bottomInset;

  /// Per-instance style overrides.
  final JustSheetStyle? style;

  /// Whether to wrap the inner content in [SafeArea] for the sheet's edge.
  final bool useSafeArea;

  const JustSheetSurface({
    super.key,
    required this.child,
    this.direction = .bottom,
    this.showHandle = false,
    this.size,
    this.maxSize,
    this.bottomInset,
    this.style,
    this.useSafeArea = false,
  });

  (double?, double?, BoxConstraints?) _resolveDimensions(
    BuildContext context,
    BoxConstraints constraints,
    bool isVertical,
  ) {
    double? width;
    double? height;
    BoxConstraints? boxConstraints;
    if (size != null || maxSize != null) {
      final Size screenSize = MediaQuery.sizeOf(context);
      final double axisViewport = isVertical
          ? screenSize.height
          : screenSize.width;
      final double? maxExtent = maxSize != null && maxSize!.isFinite
          ? (axisViewport * maxSize!).clamp(0.0, .infinity)
          : null;
      if (size != null) {
        double extent = axisViewport * size!;
        if (maxExtent != null) {
          extent = extent.clamp(0.0, maxExtent);
        }
        if (isVertical) {
          height = extent;
        } else {
          width = extent;
        }
      } else if (maxExtent != null) {
        boxConstraints = isVertical
            ? BoxConstraints(maxHeight: maxExtent)
            : BoxConstraints(maxWidth: maxExtent);
      }
    }
    if (isVertical && constraints.hasBoundedWidth) {
      width = .infinity;
    } else if (!isVertical && constraints.hasBoundedHeight) {
      height = .infinity;
    }
    return (width, height, boxConstraints);
  }

  Widget _buildColumn(
    BuildContext context,
    BoxConstraints constraints,
    _ResolvedSheetStyle resolved,
    bool isVertical,
    bool hasMaxConstraint,
  ) {
    final JustColorScheme colors = context.justColors;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustTypographyScheme typography = context.justTypo;
    final bool expandChild =
        size != null && (isVertical || constraints.hasBoundedHeight);
    final bool hasBoundedMainAxis =
        isVertical && (constraints.hasBoundedHeight || hasMaxConstraint);

    final Widget styledChild = DefaultTextStyle(
      style: typography.bodyMd.copyWith(color: colors.textPrimary),
      child: IconTheme.merge(
        data: IconThemeData(color: colors.textPrimary),
        child: child,
      ),
    );

    final Widget bodyChild = expandChild
        ? Expanded(child: styledChild)
        : (hasBoundedMainAxis
              ? Flexible(fit: .loose, child: styledChild)
              : styledChild);

    return Column(
      mainAxisSize: expandChild ? .max : .min,
      crossAxisAlignment:
          (isVertical ? constraints.hasBoundedWidth : size != null)
          ? .stretch
          : .start,
      children: <Widget>[
        if (showHandle && isVertical)
          Center(
            child: Container(
              width: 36.0,
              height: 4.0,
              margin: .only(bottom: spacing.md),
              decoration: BoxDecoration(
                color: resolved.handleColor,
                borderRadius: .all(radius.xs),
              ),
            ),
          ),
        bodyChild,
        if (direction == .bottom && (bottomInset ?? 0.0) > 0.0)
          SizedBox(height: bottomInset),
      ],
    );
  }

  Widget _buildSurface(
    BuildContext context,
    BoxConstraints constraints,
    _ResolvedSheetStyle resolved,
  ) {
    final bool isVertical = direction == .bottom || direction == .top;
    final (double? width, double? height, BoxConstraints? boxConstraints) =
        _resolveDimensions(context, constraints, isVertical);
    final Widget column = _buildColumn(
      context,
      constraints,
      resolved,
      isVertical,
      isVertical && boxConstraints != null,
    );

    return Container(
      width: width,
      height: height,
      constraints: boxConstraints,
      decoration: BoxDecoration(
        color: resolved.backgroundColor,
        borderRadius: resolved.borderRadius,
        border: resolved.border,
        boxShadow: resolved.shadows,
      ),
      padding: resolved.padding,
      child: useSafeArea
          ? SafeArea(
              top: direction == .top,
              bottom: direction == .bottom,
              left: direction == .left,
              right: direction == .right,
              child: column,
            )
          : column,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ResolvedSheetStyle resolved = _resolveSheetStyle(
      context,
      direction,
      style,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return _buildSurface(context, constraints, resolved);
      },
    );
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double delta = details.primaryDelta! / screenHeight;

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double delta = details.primaryDelta! / screenWidth;

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
    return SlideTransition(
      position: Tween<Offset>(
        begin: _sheetSlideBeginOffset(widget.direction),
        end: .zero,
      ).animate(curved),
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    final JustMotionProfile motion = context.justMotion;
    final bool isVertical =
        widget.direction == .bottom || widget.direction == .top;
    final double bottomInset = widget.direction == .bottom
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0.0;

    Widget card = JustSheetSurface(
      direction: widget.direction,
      showHandle: widget.draggable,
      size: widget.size,
      maxSize: widget.maxSize,
      bottomInset: bottomInset,
      style: widget.style,
      useSafeArea: true,
      child: widget.content,
    );

    if (widget.draggable) {
      card = GestureDetector(
        onVerticalDragUpdate: isVertical ? _onVerticalDragUpdate : null,
        onVerticalDragEnd: isVertical ? _onDragEnd : null,
        onHorizontalDragUpdate: !isVertical ? _onHorizontalDragUpdate : null,
        onHorizontalDragEnd: !isVertical ? _onDragEnd : null,
        child: card,
      );
    }

    return RepaintBoundary(
      child: FocusScope(
        autofocus: true,
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent && event.logicalKey == .escape) {
              widget.onDismiss(null);
            }
          },
          child: Stack(
            children: <Widget>[
              Align(
                alignment: _sheetAlignment(widget.direction),
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  label: 'Sheet',
                  child: _buildAnimatedCard(context, motion, card),
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

  const JustSheetScope({
    super.key,
    required this.controller,
    required this.child,
  });

  /// Retrieves the nearest [JustSheetController] from the ancestor scope.
  static JustSheetController of(BuildContext context) {
    final _JustSheetScopeInherited? scope = context
        .dependOnInheritedWidgetOfExactType<_JustSheetScopeInherited>();
    assert(scope != null, 'No JustSheetScope found in context');
    return scope!.controller;
  }

  /// Retrieves the nearest [JustSheetController] from the ancestor scope if available.
  static JustSheetController? maybeOf(BuildContext context) {
    final _JustSheetScopeInherited? scope = context
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

class _JustSheetScopeInherited extends InheritedWidget {
  final JustSheetController controller;

  const _JustSheetScopeInherited({
    required super.child,
    required this.controller,
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

Widget _buildSheetRouteTransition(
  SheetDirection direction,
  JustMotionProfile motion,
  Animation<double> animation,
  Widget child,
) {
  final CurvedAnimation curved = CurvedAnimation(
    parent: animation,
    curve: motion.enter,
    reverseCurve: motion.exit,
  );
  return SlideTransition(
    position: Tween<Offset>(
      begin: _sheetSlideBeginOffset(direction),
      end: .zero,
    ).animate(curved),
    child: child,
  );
}

Future<T?> _showFallbackBottomSheet<T>({
  required BuildContext context,
  required Widget content,
  required SheetDirection direction,
  required bool barrierDismissable,
  Color? barrierColor,
  double? size,
  double? maxSize,
  required bool draggable,
  JustSheetStyle? style,
}) {
  final JustThemeData theme = context.readTheme();
  final JustColorScheme colors = theme.colors;
  final JustMotionProfile motion = theme.animations.resolve(context);

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
    pageBuilder:
        (
          BuildContext pageContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return Align(
            alignment: _sheetAlignment(direction),
            child: JustSheetSurface(
              direction: direction,
              showHandle: draggable,
              size: size,
              maxSize: maxSize,
              bottomInset: direction == .bottom
                  ? MediaQuery.viewInsetsOf(pageContext).bottom
                  : 0.0,
              style: style,
              useSafeArea: true,
              child: content,
            ),
          );
        },
    transitionBuilder: (
      BuildContext _,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) => _buildSheetRouteTransition(direction, motion, animation, child),
  );
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
  final JustSheetController? scope = JustSheetScope.maybeOf(context);
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
  return _showFallbackBottomSheet<T>(
    context: context,
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

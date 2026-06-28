import 'dart:async';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../overlay/just_overlay_controller.dart';
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
  final List<_DialogInstance<dynamic>> _activeDialogs = [];

  @override
  bool get isVisible => _activeDialogs.isNotEmpty;

  /// Shows a modal dialog and returns a [Future] that completes with the value
  /// passed when the dialog is dismissed or confirmed.
  Future<T?> show<T>({
    required Widget content,
    DialogPosition position = DialogPosition.center,
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

    final completer = Completer<T?>();
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final isLocalController = animationController == null;
    final animController = animationController ??
        AnimationController(
          vsync: _vsync!,
          duration: const Duration(milliseconds: 300),
        );

    late final _DialogInstance<T> instance;

    // 1. Barrier Entry
    final barrierEntry = OverlayEntry(
      builder: (context) {
        final theme = JustThemeProvider.of(context).theme;
        final colors = theme.colors;
        final resolvedBarrierColor = style?.barrierColor ??
            barrierColor ??
            colors.overlay.withValues(alpha: 0.5);

        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animController,
            curve: Curves.linear,
          ),
          child: GestureDetector(
            onTap: barrierDismissable ? () => _dismissDialog(instance, null) : null,
            child: Container(
              color: resolvedBarrierColor,
            ),
          ),
        );
      },
    );

    // Save current focus to restore it later
    final previousFocus = FocusManager.instance.primaryFocus;

    // 2. Content Entry
    final contentEntry = OverlayEntry(
      builder: (context) {
        return _JustDialogWidget(
          instance: instance,
          content: content,
          position: position,
          style: style,
          animationBuilder: animationBuilder,
          previousFocus: previousFocus,
          onDismiss: (val) => _dismissDialog(instance, val),
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
    if (!_activeDialogs.contains(instance)) return;

    instance.animationController.reverse().then((_) {
      instance.barrierEntry.remove();
      instance.barrierEntry.dispose();
      instance.contentEntry.remove();
      instance.contentEntry.dispose();

      if (instance.isLocalController) {
        instance.animationController.dispose();
      }

      _activeDialogs.remove(instance);
      if (!instance.completer.isCompleted) {
        instance.completer.complete(result);
      }
    });
  }

  @override
  void dismiss() {
    final targets = List<_DialogInstance<dynamic>>.from(_activeDialogs);
    for (final dialog in targets) {
      _dismissDialog(dialog, null);
    }
  }

  @override
  void dispose() {
    dismiss();
  }
}

/// The internal widget for rendering the dialog content with focus trapping and keyboard shortcuts.
class _JustDialogWidget extends StatefulWidget {
  final _DialogInstance<dynamic> instance;
  final Widget content;
  final DialogPosition position;
  final JustDialogStyle? style;
  final JustOverlayAnimationBuilder? animationBuilder;
  final FocusNode? previousFocus;
  final ValueChanged<dynamic> onDismiss;

  const _JustDialogWidget({
    required this.instance,
    required this.content,
    required this.position,
    this.style,
    this.animationBuilder,
    this.previousFocus,
    required this.onDismiss,
  });

  @override
  State<_JustDialogWidget> createState() => _JustDialogWidgetState();
}

class _JustDialogWidgetState extends State<_JustDialogWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    // Restore focus asynchronously after the frame to prevent layout/focus conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.previousFocus?.requestFocus();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final colors = theme.colors;
    final spacing = theme.spacing;
    final radius = theme.radius;
    final shadows = theme.shadows;
    final motion = theme.animations.resolve(context);

    final globalTheme = Theme.of(context).extension<JustDialogTheme>();
    
    JustDialogStyle? positionThemeStyle;
    switch (widget.position) {
      case DialogPosition.center:
        positionThemeStyle = globalTheme?.centerStyle;
        break;
      case DialogPosition.bottom:
        positionThemeStyle = globalTheme?.bottomStyle;
        break;
      case DialogPosition.top:
        positionThemeStyle = globalTheme?.topStyle;
        break;
    }

    final entryStyle = widget.style;

    // Resolve visual styles
    final bgColor = entryStyle?.backgroundColor ??
        positionThemeStyle?.backgroundColor ??
        colors.card;
    final padding = entryStyle?.padding ??
        positionThemeStyle?.padding ??
        .all(spacing.lg);
    final maxWidth = entryStyle?.maxWidth ??
        positionThemeStyle?.maxWidth ??
        (widget.position == DialogPosition.center ? 480.0 : double.infinity);
    final maxHeight = entryStyle?.maxHeight ??
        positionThemeStyle?.maxHeight;
    final dialogShadows = entryStyle?.shadows ??
        positionThemeStyle?.shadows ??
        shadows.lg;

    final BorderRadius resolvedRadius;
    switch (widget.position) {
      case DialogPosition.center:
        resolvedRadius = entryStyle?.borderRadius ??
            positionThemeStyle?.borderRadius ??
            .all(radius.lg);
        break;
      case DialogPosition.bottom:
        resolvedRadius = entryStyle?.borderRadius ??
            positionThemeStyle?.borderRadius ??
            .vertical(top: radius.lg);
        break;
      case DialogPosition.top:
        resolvedRadius = entryStyle?.borderRadius ??
            positionThemeStyle?.borderRadius ??
            .vertical(bottom: radius.lg);
        break;
    }

    final isNeobrutalism = theme.preset == .neobrutalism;
    final borderSide = BorderSide(
      color: isNeobrutalism ? colors.textPrimary : colors.borderDefault,
      width: isNeobrutalism ? 2.5 : 1.0,
    );

    // Layout alignment on screen
    Alignment alignment;
    switch (widget.position) {
      case DialogPosition.center:
        alignment = Alignment.center;
        break;
      case DialogPosition.bottom:
        alignment = Alignment.bottomCenter;
        break;
      case DialogPosition.top:
        alignment = Alignment.topCenter;
        break;
    }

    // Build dialog card container
    final Widget card = Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight ?? double.infinity,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: resolvedRadius,
        border: .fromBorderSide(borderSide),
        boxShadow: theme.resolveShadows(dialogShadows, isPressed: false),
      ),
      padding: padding,
      child: SafeArea(
        top: widget.position == DialogPosition.top,
        bottom: widget.position == DialogPosition.bottom,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.position == DialogPosition.bottom) ...[
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
            ],
            widget.content,
          ],
        ),
      ),
    );

    // Apply animation
    final curvedAnimation = CurvedAnimation(
      parent: widget.instance.animationController,
      curve: motion.enter,
      reverseCurve: motion.exit,
    );

    Widget animatedChild;
    if (widget.animationBuilder != null) {
      animatedChild = widget.animationBuilder!(context, widget.instance.animationController, card);
    } else {
      switch (widget.position) {
        case DialogPosition.center:
          animatedChild = FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
              child: card,
            ),
          );
          break;
        case DialogPosition.bottom:
          animatedChild = SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curvedAnimation),
            child: card,
          );
          break;
        case DialogPosition.top:
          animatedChild = SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(curvedAnimation),
            child: card,
          );
          break;
      }
    }

    // Wrap with focus trapping and keyboard navigation
    return RepaintBoundary(
      child: FocusScope(
        autofocus: true,
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onDismiss(null);
            }
          },
          child: Stack(
            children: [
              Align(
                alignment: alignment,
                child: Padding(
                  padding: widget.position == DialogPosition.center
                      ? .all(spacing.lg)
                      : .zero,
                  child: Semantics(
                    scopesRoute: true,
                    namesRoute: true,
                    label: 'Dialog',
                    child: animatedChild,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scope widget that binds a [JustDialogController] and handles the Flutter context/ticker binding.
class JustDialogScope extends StatefulWidget {
  /// The controller that manages the dialog overlay.
  final JustDialogController controller;

  /// The child subtree.
  final Widget child;

  /// Creates a [JustDialogScope].
  const JustDialogScope({
    super.key,
    required this.controller,
    required this.child,
  });

  /// Retrieves the nearest [JustDialogController] from the ancestor scope.
  static JustDialogController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_JustDialogScopeInherited>();
    assert(scope != null, 'No JustDialogScope found in context');
    return scope!.controller;
  }

  @override
  State<JustDialogScope> createState() => _JustDialogScopeState();
}

class _JustDialogScopeState extends State<JustDialogScope> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller._vsync = this;
  }

  @override
  void didUpdateWidget(covariant JustDialogScope oldWidget) {
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
    return _JustDialogScopeInherited(
      controller: widget.controller,
      child: widget.child,
    );
  }
}

class _JustDialogScopeInherited extends InheritedWidget {
  final JustDialogController controller;

  const _JustDialogScopeInherited({
    required this.controller,
    required super.child,
  });

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

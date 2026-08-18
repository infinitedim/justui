import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart' show HapticFeedback, KeyDownEvent;
import 'package:flutter/widgets.dart';

/// Holds the active interaction states of a pressable element.
class const JustInteractionState(
  final bool isHovered,
  final bool isPressed,
  final bool isFocused,
  final bool isFocusVisible,
  final FocusNode focusNode,
);

/// A builder function that provides the active interactive states of a pressable element.
typedef JustPressableBuilder = Widget Function(
  BuildContext context,
  JustInteractionState state,
);

/// A utility component that manages hover, press, and focus state machines.
///
/// Encapsulates primitive widgets (`Focus`, `MouseRegion`, `GestureDetector`) and
/// exposes their states via [JustPressableBuilder] using [ValueNotifier] to isolate rebuilds.
class const JustPressable({
  required final JustPressableBuilder builder,
  super.key,
  final bool enabled = true,
  final VoidCallback? onTap,
  final FocusNode? focusNode,
  final FocusOnKeyEventCallback? onKeyEvent,
  final bool? enableHapticFeedback,
  final String? semanticLabel,
}) extends StatefulWidget {
  @override
  State<JustPressable> createState() => _JustPressableState();
}

class _JustPressableState extends State<JustPressable> {
  late final FocusNode _focusNode;
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isFocusVisible = ValueNotifier<bool>(false);
  late final Listenable _statesListenable;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
    _statesListenable = .merge([
      _isHovered,
      _isPressed,
      _isFocused,
      _isFocusVisible,
    ]);
  }

  @override
  void didUpdateWidget(covariant JustPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _focusNode.removeListener(_onFocusChanged);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _isHovered.dispose();
    _isPressed.dispose();
    _isFocused.dispose();
    _isFocusVisible.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    _isFocused.value = _focusNode.hasFocus;
    _updateFocusVisible();
  }

  void _onHighlightModeChanged(FocusHighlightMode mode) {
    _updateFocusVisible();
  }

  void _updateFocusVisible() {
    _isFocusVisible.value =
        _focusNode.hasFocus &&
        FocusManager.instance.highlightMode == .traditional;
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _isPressed.value = true;
      final shouldHaptic =
          widget.enableHapticFeedback ??
          (defaultTargetPlatform == .iOS || defaultTargetPlatform == .android);
      if (shouldHaptic) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _isPressed.value = false;
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      _isPressed.value = false;
    }
  }

  void _handleMouseEnter(PointerEvent event) {
    if (widget.enabled) {
      _isHovered.value = true;
    }
  }

  void _handleMouseExit(PointerEvent event) {
    if (widget.enabled) {
      _isHovered.value = false;
      _isPressed.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Focus(
      focusNode: _focusNode,
      canRequestFocus: widget.enabled,
      onKeyEvent:
          widget.onKeyEvent ??
          (node, event) {
            if (!widget.enabled ||
                widget.onTap == null ||
                event is! KeyDownEvent) {
              return .ignored;
            }
            if (event.logicalKey == .space || event.logicalKey == .enter) {
              widget.onTap!();
              return .handled;
            }
            return .ignored;
          },
      child: MouseRegion(
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedBuilder(
            animation: _statesListenable,
            builder: (context, _) {
              return widget.builder(
                context,
                JustInteractionState(
                  widget.enabled && _isHovered.value,
                  widget.enabled && _isPressed.value,
                  widget.enabled && _isFocused.value,
                  widget.enabled && _isFocusVisible.value,
                  _focusNode,
                ),
              );
            },
          ),
        ),
      ),
    );

    if (widget.semanticLabel != null) {
      content = Semantics(
        button: true,
        label: widget.semanticLabel,
        enabled: widget.enabled,
        child: content,
      );
    }

    return content;
  }
}

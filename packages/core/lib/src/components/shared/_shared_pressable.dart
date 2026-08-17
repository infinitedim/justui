import 'package:flutter/services.dart' show KeyDownEvent;
import 'package:flutter/widgets.dart';

/// A builder function that provides the active interactive states of a pressable element.
typedef JustPressableBuilder =
    Widget Function(
      BuildContext context,
      bool isHovered,
      bool isPressed,
      bool isFocused,
      FocusNode focusNode,
    );

/// A utility component that manages hover, press, and focus state machines.
///
/// Encapsulates primitive widgets (`Focus`, `MouseRegion`, `GestureDetector`) and
/// exposes their states via [JustPressableBuilder] using [ValueNotifier] to isolate rebuilds.
class JustPressable extends StatefulWidget {
  /// Whether this element is interactive.
  final bool enabled;

  /// Callback when the element is tapped.
  final VoidCallback? onTap;

  /// Optional external [FocusNode] to control or monitor focus.
  final FocusNode? focusNode;

  /// Optional custom key event handler for keyboard navigation.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Builder that returns the styled widget tree based on the interactive states.
  final JustPressableBuilder builder;

  /// Creates a [JustPressable] component.
  const JustPressable({
    super.key,
    this.enabled = true,
    this.onTap,
    this.focusNode,
    this.onKeyEvent,
    required this.builder,
  });

  @override
  State<JustPressable> createState() => _JustPressableState();
}

class _JustPressableState extends State<JustPressable> {
  late final FocusNode _focusNode;
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isFocused = ValueNotifier<bool>(false);
  late final Listenable _statesListenable;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    _statesListenable = Listenable.merge([_isHovered, _isPressed, _isFocused]);
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
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _isHovered.dispose();
    _isPressed.dispose();
    _isFocused.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    _isFocused.value = _focusNode.hasFocus;
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _isPressed.value = true;
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
    return Focus(
      focusNode: _focusNode,
      canRequestFocus: widget.enabled,
      onKeyEvent: widget.onKeyEvent ??
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
                widget.enabled && _isHovered.value,
                widget.enabled && _isPressed.value,
                widget.enabled && _isFocused.value,
                _focusNode,
              );
            },
          ),
        ),
      ),
    );
  }
}

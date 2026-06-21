import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import '../../theme/theme_provider.dart';
import '../shared/just_focus_indicator.dart';
import '../shared/just_pressable.dart';
import 'just_switch_style.dart';
import 'just_switch_theme.dart';

/// A highly customizable, performant, and accessible Switch component.
///
/// Follows zero-Material visual widget policy and supports smooth 60fps translation
/// animations via [Transform.translate], haptic feedback, tap-to-toggle, drag-to-toggle,
/// and keyboard navigation.
class JustSwitch extends StatefulWidget {
  /// Whether the switch is active (ON) or inactive (OFF).
  final bool value;

  /// Callback executed when the switch state changes.
  /// If null, the switch is disabled.
  final ValueChanged<bool>? onChanged;

  /// Optional text label placed alongside the switch. Tapping the label also toggles the switch.
  final Widget? label;

  /// The size classification for the switch track. Defaults to [.md].
  final JustSwitchSize size;

  /// Whether the switch is explicitly disabled.
  final bool isDisabled;

  /// Per-instance style overrides.
  final JustSwitchStyle? style;

  /// Whether to trigger haptic feedback on toggles.
  /// If null, falls back to the theme extension setting.
  final bool? enableHaptic;

  /// Optional active track color override.
  final Color? activeColor;

  /// Optional builder to display an icon or widget inside the thumb.
  final Widget? Function(bool value)? thumbIcon;

  /// Optional external [FocusNode] to manage focus.
  final FocusNode? focusNode;

  /// Creates a [JustSwitch].
  const JustSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = .md,
    this.isDisabled = false,
    this.style,
    this.enableHaptic,
    this.activeColor,
    this.thumbIcon,
    this.focusNode,
  });

  @override
  State<JustSwitch> createState() => _JustSwitchState();
}

class _JustSwitchState extends State<JustSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late FocusNode _focusNode;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: JustDuration.fast,
      value: widget.value ? 1.0 : 0.0,
    );

    _initFocusNode();
  }

  void _initFocusNode() {
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && !widget.isDisabled) {
      if (event.logicalKey == .space || event.logicalKey == .enter) {
        _handleToggle();
        return .handled;
      }
    }
    return .ignored;
  }

  @override
  void didUpdateWidget(JustSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.onKeyEvent = null;
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _initFocusNode();
    }
    if (widget.value != oldWidget.value && !_isDragging) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.onKeyEvent = null;
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleToggle() {
    if (widget.isDisabled || widget.onChanged == null) return;
    _triggerToggle(!widget.value);
  }

  void _triggerToggle(bool newValue) {
    final switchTheme = Theme.of(context).extension<JustSwitchTheme>();
    final finalEnableHaptic =
        widget.enableHaptic ??
        switchTheme?.enableHaptic ??
        (JustThemeProvider.read(context).theme.preset == .neobrutalism);

    if (finalEnableHaptic) {
      HapticFeedback.selectionClick();
    }
    widget.onChanged?.call(newValue);
  }

  void _handleDragStart(DragStartDetails details) {
    if (widget.isDisabled || widget.onChanged == null) return;
    _isDragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxTravel) {
    if (!_isDragging) return;
    final delta = details.primaryDelta ?? 0.0;
    _controller.value = (_controller.value + delta / maxTravel).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final targetValue = _controller.value >= 0.5;
    if (targetValue != widget.value) {
      _triggerToggle(targetValue);
      if (targetValue) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } else {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final switchTheme = Theme.of(context).extension<JustSwitchTheme>();

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;

    final isInteractive = !widget.isDisabled && widget.onChanged != null;

    final isNeobrutalism = customTheme.preset == .neobrutalism;
    final borderWidth = isNeobrutalism ? 2.0 : 0.0;

    // Resolve sizing values
    double trackWidth;
    double trackHeight;
    double thumbSize;
    TextStyle textStyle;

    switch (widget.size) {
      case .sm:
        trackWidth = 32.0;
        trackHeight = 18.0;
        thumbSize = 14.0;
        textStyle = typography.bodySm;
        break;
      case .md:
        trackWidth = 40.0;
        trackHeight = 22.0;
        thumbSize = 18.0;
        textStyle = typography.bodyMd;
        break;
      case .lg:
        trackWidth = 48.0;
        trackHeight = 26.0;
        thumbSize = 22.0;
        textStyle = typography.bodyLg;
        break;
    }

    final resolvedThumbSize = isNeobrutalism
        ? thumbSize - 2 * borderWidth
        : thumbSize;

    // Resolve theme styles
    final themeStyle = switchTheme?.style;
    final resolvedActiveTrackColor =
        widget.activeColor ??
        widget.style?.activeTrackColor ??
        themeStyle?.activeTrackColor ??
        (isNeobrutalism ? colors.success : colors.borderFocus);
    final resolvedInactiveTrackColor =
        widget.style?.inactiveTrackColor ??
        themeStyle?.inactiveTrackColor ??
        (isNeobrutalism ? colors.background : colors.borderDefault);
    final resolvedActiveThumbColor =
        widget.style?.activeThumbColor ??
        themeStyle?.activeThumbColor ??
        colors.textInverse;
    final resolvedInactiveThumbColor =
        widget.style?.inactiveThumbColor ??
        themeStyle?.inactiveThumbColor ??
        colors.textInverse;
    final resolvedTextStyle =
        widget.style?.textStyle ??
        themeStyle?.textStyle ??
        textStyle.copyWith(color: colors.textPrimary);

    const double padding = 2.0;
    final double maxTravel =
        trackWidth - padding * 2 - resolvedThumbSize - borderWidth * 2;

    return Semantics(
      toggled: widget.value,
      enabled: isInteractive,
      label: 'Switch',
      child: JustPressable(
        enabled: isInteractive,
        onTap: _handleToggle,
        focusNode: _focusNode,
        builder: (context, isHovered, isPressed, isFocused, focusNode) {
          return Opacity(
            opacity: widget.isDisabled ? 0.5 : 1.0,
            child: Row(
              mainAxisSize: .min,
              crossAxisAlignment: .center,
              children: [
                // Accessibility touch target constraint (minimum 48x48)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48.0,
                    minHeight: 48.0,
                  ),
                  child: Center(
                    child: RepaintBoundary(
                      child: FocusIndicator(
                        isFocused: isFocused,
                        focusColor: colors.borderFocus,
                        borderRadius: .all(.circular(trackHeight / 2)),
                        child: GestureDetector(
                          onHorizontalDragStart: _handleDragStart,
                          onHorizontalDragUpdate: (details) =>
                              _handleDragUpdate(details, maxTravel),
                          onHorizontalDragEnd: _handleDragEnd,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final progress = _controller.value;

                              // LERP track and thumb colors
                              final Color currentTrackColor = .lerp(
                                resolvedInactiveTrackColor,
                                resolvedActiveTrackColor,
                                progress,
                              )!;

                              final Color currentThumbColor = .lerp(
                                resolvedInactiveThumbColor,
                                resolvedActiveThumbColor,
                                progress,
                              )!;

                              return Container(
                                width: trackWidth,
                                height: trackHeight,
                                decoration: BoxDecoration(
                                  color: currentTrackColor,
                                  borderRadius: .all(
                                    .circular(trackHeight / 2),
                                  ),
                                  border: isNeobrutalism
                                      ? .all(
                                          color: colors.textPrimary,
                                          width: borderWidth,
                                        )
                                      : null,
                                ),
                                child: Stack(
                                  clipBehavior: .none,
                                  children: [
                                    Positioned(
                                      left: padding + borderWidth,
                                      top: padding + borderWidth,
                                      child: Transform.translate(
                                        offset: Offset(
                                          progress * maxTravel,
                                          0.0,
                                        ),
                                        child: Container(
                                          width: resolvedThumbSize,
                                          height: resolvedThumbSize,
                                          decoration: BoxDecoration(
                                            color: currentThumbColor,
                                            shape: .circle,
                                            border: isNeobrutalism
                                                ? .all(
                                                    color: colors.textPrimary,
                                                    width: 1.5,
                                                  )
                                                : null,
                                            boxShadow: isNeobrutalism
                                                ? null
                                                : customTheme.shadows.xs,
                                          ),
                                          child: widget.thumbIcon != null
                                              ? Center(
                                                  child: widget.thumbIcon!(
                                                    widget.value,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.label != null) ...[
                  SizedBox(width: spacing.sm),
                  DefaultTextStyle(
                    style: resolvedTextStyle,
                    child: widget.label!,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

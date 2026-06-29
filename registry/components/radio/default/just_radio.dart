import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../../shared/default/_shared_tokens.dart';
import '../../theme/theme_provider.dart';
import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import 'just_radio_style.dart';
import 'just_radio_theme.dart';

/// A highly customizable, performant, and accessible Radio button component.
///
/// Follows zero-Material visual widget policy and supports custom animated
/// dot painting via [CustomPainter], haptic feedback, and keyboard navigation.
class JustRadio<T> extends StatefulWidget {
  /// The unique value associated with this radio button.
  final T value;

  /// The currently selected value in the radio group.
  final T? groupValue;

  /// Callback executed when this radio button is selected.
  /// If null, the radio is disabled.
  final ValueChanged<T>? onChanged;

  /// Optional text label placed alongside the radio button. Tapping the label selects the radio.
  final Widget? label;

  /// The size of the visual radio circle. Defaults to [.md].
  final JustRadioSize size;

  /// Whether the radio is explicitly disabled.
  final bool isDisabled;

  /// Per-instance style overrides.
  final JustRadioStyle? style;

  /// Whether to trigger haptic feedback on selection.
  /// If null, falls back to the theme extension setting.
  final bool? enableHaptic;

  /// Optional external [FocusNode] to manage focus.
  final FocusNode? focusNode;

  /// Creates a [JustRadio].
  const JustRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.size = .md,
    this.isDisabled = false,
    this.style,
    this.enableHaptic,
    this.focusNode,
  });

  @override
  State<JustRadio<T>> createState() => _JustRadioState<T>();
}

class _JustRadioState<T> extends State<JustRadio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late FocusNode _focusNode;

  bool get _isSelected => widget.value == widget.groupValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: JustDuration.fast,
      value: _isSelected ? 1.0 : 0.0,
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
        _handleSelect();
        return .handled;
      }
    }
    return .ignored;
  }

  @override
  void didUpdateWidget(JustRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.onKeyEvent = null;
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _initFocusNode();
    }
    if (_isSelected != (oldWidget.value == oldWidget.groupValue)) {
      if (_isSelected) {
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

  void _handleSelect() {
    if (widget.isDisabled || widget.onChanged == null) return;
    if (!_isSelected) {
      final radioTheme = Theme.of(context).extension<JustRadioTheme>();
      final finalEnableHaptic =
          widget.enableHaptic ??
          radioTheme?.enableHaptic ??
          (JustThemeProvider.read(context).theme.preset == .neobrutalism);

      if (finalEnableHaptic) {
        HapticFeedback.selectionClick();
      }

      widget.onChanged?.call(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radioTheme = Theme.of(context).extension<JustRadioTheme>();

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

    // Resolve sizing values
    double circleSize;
    TextStyle textStyle;

    switch (widget.size) {
      case .sm:
        circleSize = 16.0;
        textStyle = typography.bodySm;
        break;
      case .md:
        circleSize = 20.0;
        textStyle = typography.bodyMd;
        break;
      case .lg:
        circleSize = 24.0;
        textStyle = typography.bodyLg;
        break;
    }

    // Resolve theme styles
    final themeStyle = radioTheme?.style;
    final resolvedActiveColor =
        widget.style?.activeColor ??
        themeStyle?.activeColor ??
        colors.borderFocus;
    final resolvedBorderColor =
        widget.style?.borderColor ??
        themeStyle?.borderColor ??
        colors.borderDefault;
    final resolvedDotColor =
        widget.style?.dotColor ?? themeStyle?.dotColor ?? resolvedActiveColor;
    final resolvedTextStyle =
        widget.style?.textStyle ??
        themeStyle?.textStyle ??
        textStyle.copyWith(color: colors.textPrimary);

    final customTheme = JustThemeProvider.of(context).theme;
    final isNeobrutalism = customTheme.preset == .neobrutalism;

    return Semantics(
      checked: _isSelected,
      inMutuallyExclusiveGroup: true,
      enabled: isInteractive,
      label: 'Radio Button',
      child: JustPressable(
        enabled: isInteractive,
        onTap: _handleSelect,
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
                    // RepaintBoundary placed directly inside JustRadio visual indicator
                    child: RepaintBoundary(
                      child: FocusIndicator(
                        isFocused: isFocused,
                        focusColor: colors.borderFocus,
                        borderRadius: .all(.circular(circleSize / 2)),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final progress = _controller.value;

                            final Color currentBorder = isNeobrutalism
                                ? colors.textPrimary
                                : (isHovered
                                      ? colors.textSecondary
                                      : .lerp(
                                          resolvedBorderColor,
                                          resolvedActiveColor,
                                          progress,
                                        )!);

                            List<BoxShadow> currentShadows = isNeobrutalism
                                ? customTheme.shadows.xs
                                : const [];
                            currentShadows = customTheme.resolveShadows(
                              currentShadows,
                              isPressed: isPressed,
                            );

                            final radioBox = Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: .circle,
                                border: .all(
                                  color: currentBorder,
                                  width: isNeobrutalism ? 2.5 : 1.5,
                                ),
                                boxShadow: currentShadows.isNotEmpty
                                    ? currentShadows
                                    : null,
                              ),
                              child: CustomPaint(
                                painter: _RadioDotPainter(
                                  progress: progress,
                                  color: resolvedDotColor,
                                ),
                              ),
                            );

                            return customTheme.buildPressEffect(
                              isPressed: isPressed,
                              child: radioBox,
                            );
                          },
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

class _RadioDotPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RadioDotPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Dot is approximately 50% of the visual outer circle size
    final radius = (size.width / 2.0) * 0.5 * progress;
    canvas.drawCircle(size.center(Offset.zero), radius, paint);
  }

  @override
  bool shouldRepaint(_RadioDotPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

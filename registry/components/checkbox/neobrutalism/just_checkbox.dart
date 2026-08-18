import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import 'just_checkbox_style.dart';
import 'just_checkbox_theme.dart';

import 'package:just_ui_core/just_ui_core.dart';

/// A highly customizable, performant, and accessible Checkbox component.
///
/// Follows zero-Material visual widget policy and supports indeterminate state,
/// custom animated paths via [CustomPainter], haptic feedback, and keyboard navigation.
class JustCheckbox extends StatefulWidget {
  /// The current state of the checkbox:
  /// * `true` — Checked
  /// * `false` — Unchecked
  /// * `null` — Indeterminate (e.g. parent status)
  final bool? value;

  /// Callback executed when the checkbox state changes.
  /// If null, the checkbox is disabled.
  final ValueChanged<bool?>? onChanged;

  /// Optional text label placed alongside the checkbox. Tapping the label also toggles the checkbox.
  final Widget? label;

  /// The size of the visual checkbox box. Defaults to [.md].
  final JustCheckboxSize size;

  /// Whether the checkbox is explicitly disabled.
  final bool isDisabled;

  /// Per-instance style overrides.
  final JustCheckboxStyle? style;

  /// Whether to trigger haptic feedback on toggles.
  /// If null, falls back to the theme extension setting.
  final bool? enableHaptic;

  /// Optional external [FocusNode] to manage focus.
  final FocusNode? focusNode;

  /// Creates a [JustCheckbox].
  const JustCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = .md,
    this.isDisabled = false,
    this.style,
    this.enableHaptic,
    this.focusNode,
  });

  @override
  State<JustCheckbox> createState() => _JustCheckboxState();
}

class _JustCheckboxState extends State<JustCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: JustDuration.fast,
      value: widget.value != false ? 1.0 : 0.0,
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
  void didUpdateWidget(JustCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.onKeyEvent = null;
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _initFocusNode();
    }
    if (widget.value != oldWidget.value) {
      if (widget.value != false) {
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

    final checkboxTheme = Theme.of(context).extension<JustCheckboxTheme>();
    final finalEnableHaptic =
        widget.enableHaptic ??
        checkboxTheme?.enableHaptic ??
        JustThemeProvider.read(context)
            .theme
            .presetTokens
            .selectionHapticDefault;

    if (finalEnableHaptic) {
      HapticFeedback.selectionClick();
    }

    final currentValue = widget.value;
    if (currentValue == null) {
      widget.onChanged?.call(true);
    } else {
      widget.onChanged?.call(!currentValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final checkboxTheme = Theme.of(context).extension<JustCheckboxTheme>();

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = customTheme.radius;

    final isInteractive = !widget.isDisabled && widget.onChanged != null;

    // Resolve sizing values
    double boxSize;
    double strokeWidth;
    TextStyle textStyle;

    switch (widget.size) {
      case .sm:
        boxSize = 16.0;
        strokeWidth = 1.5;
        textStyle = typography.bodySm;
        break;
      case .md:
        boxSize = 20.0;
        strokeWidth = 2.0;
        textStyle = typography.bodyMd;
        break;
      case .lg:
        boxSize = 24.0;
        strokeWidth = 2.5;
        textStyle = typography.bodyLg;
        break;
    }

    // Resolve theme styles
    final themeStyle = checkboxTheme?.style;
    final hasBorderPreset = customTheme.presetTokens.showsDefaultBorder;
    final resolvedActiveColor =
        widget.style?.activeColor ??
        themeStyle?.activeColor ??
        (hasBorderPreset ? colors.warning : colors.borderFocus);
    final resolvedCheckColor =
        widget.style?.checkColor ??
        themeStyle?.checkColor ??
        (hasBorderPreset ? colors.textPrimary : colors.textInverse);
    final resolvedBorderColor =
        widget.style?.borderColor ??
        themeStyle?.borderColor ??
        colors.borderDefault;
    final resolvedRadius =
        widget.style?.borderRadius ??
        themeStyle?.borderRadius ??
        (hasBorderPreset ? .zero : .all(radius.xs));
    final resolvedTextStyle =
        widget.style?.textStyle ??
        themeStyle?.textStyle ??
        textStyle.copyWith(color: colors.textPrimary);

    return Semantics(
      checked: widget.value == true,
      mixed: widget.value == null,
      enabled: isInteractive,
      label: 'Checkbox',
      child: JustPressable(
        enabled: isInteractive,
        onTap: _handleToggle,
        focusNode: _focusNode,
        builder: (BuildContext context, JustInteractionState state) {
          return Opacity(
            opacity: widget.isDisabled ? 0.5 : 1.0,
            child: Row(
              mainAxisSize: .min,
              crossAxisAlignment: .center,
              children: [
                // Accessibility target constraint (minimum 48x48 touch target)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48.0,
                    minHeight: 48.0,
                  ),
                  child: Center(
                    child: RepaintBoundary(
                      child: FocusIndicator(
                        isFocused: state.isFocusVisible,
                        borderRadius: resolvedRadius,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final progress = _controller.value;
                            final isIndeterminate = widget.value == null;
                            final hasBorder =
                                customTheme.presetTokens.showsDefaultBorder;

                            // Interpolate colors based on checked/indeterminate progress
                            final Color currentBg = .lerp(
                              const Color(0x00000000),
                              resolvedActiveColor,
                              progress,
                            )!;

                            final Color currentBorder = hasBorder
                                ? colors.textPrimary
                                : (state.isHovered
                                      ? colors.textSecondary
                                      : .lerp(
                                          resolvedBorderColor,
                                          resolvedActiveColor,
                                          progress,
                                        )!);

                            final List<BoxShadow> currentShadows = hasBorder
                                ? customTheme.presetTokens.resolveShadow(
                                    customTheme.shadows,
                                    JustShadowLevel.sm,
                                    isPressed: state.isPressed,
                                  )
                                : const [];

                            final checkboxBox = Container(
                              width: boxSize,
                              height: boxSize,
                              decoration: BoxDecoration(
                                color: currentBg,
                                borderRadius: resolvedRadius,
                                border: .all(
                                  color: currentBorder,
                                  width: hasBorder
                                      ? customTheme.presetTokens.borderWidth
                                      : 1.5,
                                ),
                                boxShadow: currentShadows.isNotEmpty
                                    ? currentShadows
                                    : null,
                              ),
                              child: isIndeterminate
                                  ? CustomPaint(
                                      painter: _IndeterminatePainter(
                                        progress: progress,
                                        color: resolvedCheckColor,
                                        strokeWidth: strokeWidth,
                                      ),
                                    )
                                  : CustomPaint(
                                      painter: _CheckmarkPainter(
                                        progress: progress,
                                        color: resolvedCheckColor,
                                        strokeWidth: strokeWidth,
                                      ),
                                    ),
                            );

                            return customTheme.presetTokens.buildPressEffect(
                              isPressed: state.isPressed,
                              animations: customTheme.animations,
                              customOffset: const Offset(1.0, 1.0),
                              child: checkboxBox,
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

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..style = .stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = .round
      ..strokeJoin = .round;

    final start = Offset(size.width * 0.26, size.height * 0.50);
    final pivot = Offset(size.width * 0.44, size.height * 0.68);
    final end = Offset(size.width * 0.74, size.height * 0.32);

    final path = Path();
    path.moveTo(start.dx, start.dy);

    if (progress <= 0.5) {
      final t = progress / 0.5;
      final currentX = start.dx + (pivot.dx - start.dx) * t;
      final currentY = start.dy + (pivot.dy - start.dy) * t;
      path.lineTo(currentX, currentY);
    } else {
      path.lineTo(pivot.dx, pivot.dy);
      final t = (progress - 0.5) / 0.5;
      final currentX = pivot.dx + (end.dx - pivot.dx) * t;
      final currentY = pivot.dy + (end.dy - pivot.dy) * t;
      path.lineTo(currentX, currentY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _IndeterminatePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _IndeterminatePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..style = .stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = .round;

    final startX = size.width * (0.5 - 0.22 * progress);
    final endX = size.width * (0.5 + 0.22 * progress);
    final y = size.height * 0.5;

    canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
  }

  @override
  bool shouldRepaint(_IndeterminatePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

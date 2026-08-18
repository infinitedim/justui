import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart' show HapticFeedback, KeyDownEvent;
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

import '../shared/_shared_focus_indicator.dart';
import 'just_slider_style.dart';
import 'just_slider_theme.dart';
import 'package:just_ui_core/just_ui_core.dart';

/// A lightweight representation of range values for [JustSlider.range].
class JustRangeValues {
  /// The minimum value of the range.
  final double start;

  /// The maximum value of the range.
  final double end;

  /// Creates a [JustRangeValues] instance.
  const JustRangeValues(this.start, this.end) : assert(start <= end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JustRangeValues && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() =>
      'JustRangeValues(${start.toStringAsFixed(2)}, ${end.toStringAsFixed(2)})';
}

/// A premium, highly customizable slider component supporting both Single and Range modes
/// with out-of-the-box support for Default and Neobrutalism presets.
class JustSlider extends StatefulWidget {
  /// The current value of the slider (for single-value mode).
  final double? value;

  /// The current range values of the slider (for range-value mode).
  final JustRangeValues? rangeValues;

  /// Callback when the value changes.
  final ValueChanged<double>? onChanged;

  /// Callback when the range values change.
  final ValueChanged<JustRangeValues>? onRangeChanged;

  /// The minimum value of the slider.
  final double min;

  /// The maximum value of the slider.
  final double max;

  /// The number of discrete divisions. If specified, the slider will snap to these steps.
  final int? divisions;

  /// Whether to show a floating value tooltip above the active thumb during drag.
  final bool showTooltip;

  /// Whether to enable haptic feedback on value/step changes.
  final bool? enableHaptic;

  /// The size classification for the slider.
  final JustSliderSize size;

  /// Customized style overrides.
  final JustSliderStyle? style;

  /// Creates a single-value [JustSlider].
  const JustSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.showTooltip = false,
    this.enableHaptic,
    this.size = .md,
    this.style,
  }) : rangeValues = null,
       onRangeChanged = null,
       assert(min <= max);

  /// Creates a range-value [JustSlider.range].
  const JustSlider.range({
    super.key,
    required this.rangeValues,
    required this.onRangeChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.showTooltip = false,
    this.enableHaptic,
    this.size = .md,
    this.style,
  }) : value = null,
       onChanged = null,
       assert(min <= max);

  @override
  State<JustSlider> createState() => _JustSliderState();
}

class _JustSliderState extends State<JustSlider> {
  // Index of the thumb currently being dragged: -1 = none, 0 = start/single, 1 = end
  int _activeThumbIndex = -1;

  // Track last snapped values to trigger haptic feedback exactly when snapping to a new step
  double? _lastHapticValue;
  JustRangeValues? _lastHapticRangeValues;

  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  bool get _isRange => widget.rangeValues != null;

  double get _currentStart =>
      _isRange ? widget.rangeValues!.start : widget.value!;
  double get _currentEnd => _isRange ? widget.rangeValues!.end : widget.value!;

  void _increaseValue() {
    if (widget.max <= widget.min) return;
    final double range = widget.max - widget.min;
    final double step = (widget.divisions != null && widget.divisions! > 0)
        ? range / widget.divisions!
        : range / 20.0;

    if (_isRange) {
      final newEnd = (_currentEnd + step).clamp(_currentStart, widget.max);
      widget.onRangeChanged?.call(JustRangeValues(_currentStart, newEnd));
    } else {
      final newValue = (_currentStart + step).clamp(widget.min, widget.max);
      widget.onChanged?.call(newValue);
    }
  }

  void _decreaseValue() {
    if (widget.max <= widget.min) return;
    final double range = widget.max - widget.min;
    final double step = (widget.divisions != null && widget.divisions! > 0)
        ? range / widget.divisions!
        : range / 20.0;

    if (_isRange) {
      final newStart = (_currentStart - step).clamp(widget.min, _currentEnd);
      widget.onRangeChanged?.call(JustRangeValues(newStart, _currentEnd));
    } else {
      final newValue = (_currentStart - step).clamp(widget.min, widget.max);
      widget.onChanged?.call(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context);
    final presetTokens = theme.theme.presetTokens;

    final globalTheme = Theme.of(context).extension<JustSliderTheme>();
    final finalEnableHaptic =
        widget.enableHaptic ??
        globalTheme?.enableHaptic ??
        presetTokens.sliderDefaultHaptic;

    // Resolve size metrics
    final double trackHeight = presetTokens.resolveSliderTrackHeight(
      widget.size,
    );
    final double thumbSize = presetTokens.resolveSliderThumbSize(widget.size);

    // Resolve colors
    final colors = theme.theme.colors;
    final activeTrackColor =
        widget.style?.activeTrackColor ??
        globalTheme?.style?.activeTrackColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderFocus);
    final inactiveTrackColor =
        widget.style?.inactiveTrackColor ??
        globalTheme?.style?.inactiveTrackColor ??
        (presetTokens.showsDefaultBorder
            ? colors.background
            : colors.borderDefault);
    final thumbColor =
        widget.style?.thumbColor ??
        globalTheme?.style?.thumbColor ??
        (presetTokens.showsDefaultBorder ? colors.warning : colors.background);
    final thumbBorderColor =
        widget.style?.thumbBorderColor ??
        globalTheme?.style?.thumbBorderColor ??
        colors.textPrimary;
    final tickMarkColor =
        widget.style?.tickMarkColor ??
        globalTheme?.style?.tickMarkColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault);

    final BorderRadius trackBorderRadius =
        widget.style?.borderRadius ??
        globalTheme?.style?.borderRadius ??
        (presetTokens.showsDefaultBorder
            ? .all(theme.theme.radius.xs)
            : .all(theme.theme.radius.full));

    const sliderHeight = 48.0;

    final isInteractive = (_isRange
        ? widget.onRangeChanged != null
        : widget.onChanged != null);

    return Semantics(
      slider: true,
      enabled: isInteractive,
      value: _isRange
          ? '${_currentStart.toStringAsFixed(1)} - ${_currentEnd.toStringAsFixed(1)}'
          : _currentStart.toStringAsFixed(1),
      onIncrease: isInteractive ? _increaseValue : null,
      onDecrease: isInteractive ? _decreaseValue : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final usableWidth = totalWidth - thumbSize;
          final range = widget.max - widget.min;

          // Calculate visual positions (0.0 to 1.0) with zero-range / NaN guard
          final double startFraction = (usableWidth <= 0 || range <= 0)
              ? 0.0
              : ((_currentStart - widget.min) / range).clamp(0.0, 1.0);
          final double endFraction = (usableWidth <= 0 || range <= 0)
              ? 0.0
              : ((_currentEnd - widget.min) / range).clamp(0.0, 1.0);

          final double startPosition = startFraction * usableWidth;
          final double endPosition = endFraction * usableWidth;

          return Focus(
            focusNode: _focusNode,
            canRequestFocus: isInteractive,
            onKeyEvent: (node, event) {
              if (!isInteractive || event is! KeyDownEvent) return .ignored;
              if (event.logicalKey == .arrowLeft ||
                  event.logicalKey == .arrowDown) {
                _decreaseValue();
                return .handled;
              }
              if (event.logicalKey == .arrowRight ||
                  event.logicalKey == .arrowUp) {
                _increaseValue();
                return .handled;
              }
              return .ignored;
            },
            child: FocusIndicator(
              isFocused:
                  _isFocused &&
                  FocusManager.instance.highlightMode ==
                      FocusHighlightMode.traditional,
              borderRadius: trackBorderRadius,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) => _handleDragStart(
                  details.localPosition.dx,
                  startPosition,
                  endPosition,
                  thumbSize,
                  usableWidth,
                  finalEnableHaptic,
                ),
                onPanUpdate: (details) => _handleDragUpdate(
                  details.localPosition.dx,
                  usableWidth,
                  finalEnableHaptic,
                ),
                onPanEnd: (_) => _handleDragEnd(),
                onTapDown: (details) {
                  _handleDragStart(
                    details.localPosition.dx,
                    startPosition,
                    endPosition,
                    thumbSize,
                    usableWidth,
                    finalEnableHaptic,
                  );
                  _handleDragUpdate(
                    details.localPosition.dx,
                    usableWidth,
                    finalEnableHaptic,
                  );
                  _handleDragEnd();
                },
                child: SizedBox(
                  height: sliderHeight,
                  child: Stack(
                    clipBehavior: .none,
                    alignment: .centerLeft,
                    children: [
                      // 1. Inactive Track (Background)
                      Container(
                        height: trackHeight,
                        width: totalWidth,
                        decoration: BoxDecoration(
                          color: inactiveTrackColor,
                          borderRadius: trackBorderRadius,
                          border: theme.theme.presetTokens.showsDefaultBorder
                              ? .all(color: colors.textPrimary, width: 2.5)
                              : null,
                        ),
                      ),

                      // 2. Active Track (Highlight)
                      Positioned(
                        left: _isRange ? (startPosition + thumbSize / 2) : 0.0,
                        width: _isRange
                            ? (endPosition - startPosition)
                            : (startPosition + thumbSize / 2),
                        child: Container(
                          height: trackHeight,
                          decoration: BoxDecoration(
                            color: activeTrackColor,
                            borderRadius: _isRange ? null : trackBorderRadius, // Rounded left edge for single mode
                            border: theme.theme.presetTokens.showsDefaultBorder
                                ? .symmetric(
                                    horizontal: BorderSide(
                                      color: colors.textPrimary,
                                      width: 2.5,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // 3. Tick Marks (if divisions specified)
                      if (widget.divisions != null)
                        ...List.generate(widget.divisions! + 1, (index) {
                          final fraction = index / widget.divisions!;
                          final tickPos =
                              fraction * usableWidth + thumbSize / 2;
                          final isTickActive = _isRange
                              ? (fraction >= startFraction &&
                                    fraction <= endFraction)
                              : (fraction <= startFraction);

                          return Positioned(
                            left: tickPos - 2.0,
                            child: Container(
                              width: 4.0,
                              height: 4.0,
                              decoration: BoxDecoration(
                                color: isTickActive
                                    ? activeTrackColor
                                    : tickMarkColor,
                                shape: .circle,
                              ),
                            ),
                          );
                        }),

                      // 4. Thumbs (with Tooltips)
                      if (_isRange) ...[
                        // Start Thumb
                        _buildThumb(
                          index: 0,
                          leftPosition: startPosition,
                          value: _currentStart,
                          thumbSize: thumbSize,
                          colors: colors,
                          thumbColor: thumbColor,
                          thumbBorderColor: thumbBorderColor,
                          theme: theme,
                        ),
                        // End Thumb
                        _buildThumb(
                          index: 1,
                          leftPosition: endPosition,
                          value: _currentEnd,
                          thumbSize: thumbSize,
                          colors: colors,
                          thumbColor: thumbColor,
                          thumbBorderColor: thumbBorderColor,
                          theme: theme,
                        ),
                      ] else ...[
                        // Single Thumb
                        _buildThumb(
                          index: 0,
                          leftPosition: startPosition,
                          value: _currentStart,
                          thumbSize: thumbSize,
                          colors: colors,
                          thumbColor: thumbColor,
                          thumbBorderColor: thumbBorderColor,
                          theme: theme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumb({
    required int index,
    required double leftPosition,
    required double value,
    required double thumbSize,
    required JustColorScheme colors,
    required Color thumbColor,
    required Color thumbBorderColor,
    required JustThemeProviderState theme,
  }) {
    final isPressed = _activeThumbIndex == index;
    final presetTokens = theme.theme.presetTokens;

    Widget thumbWidget;

    if (presetTokens.showsDefaultBorder) {
      final Offset shadowOffset = isPressed ? .zero : const Offset(2.5, 2.5);
      final Offset translation = isPressed ? const Offset(2.5, 2.5) : .zero;

      thumbWidget = AnimatedContainer(
        duration: theme.theme.animations.instant,
        curve: theme.theme.animations.defaultCurve,
        transform: Matrix4.translationValues(
          translation.dx,
          translation.dy,
          0.0,
        ),
        width: thumbSize,
        height: thumbSize,
        decoration: BoxDecoration(
          color: thumbColor,
          borderRadius: .all(theme.theme.radius.xs),
          border: .all(color: thumbBorderColor, width: 2.5),
          boxShadow: isPressed
              ? null
              : [
                  BoxShadow(
                    color: colors.textPrimary,
                    offset: shadowOffset,
                    blurRadius: 0.0,
                  ),
                ],
        ),
      );
    } else {
      thumbWidget = AnimatedScale(
        scale: isPressed ? 1.15 : 1.0,
        duration: theme.theme.animations.instant,
        curve: theme.theme.animations.defaultCurve,
        child: Container(
          width: thumbSize,
          height: thumbSize,
          decoration: BoxDecoration(
            color: thumbColor,
            shape: .circle,
            border: .all(color: thumbBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.15),
                offset: const Offset(0.0, 2.0),
                blurRadius: 4.0,
              ),
            ],
          ),
        ),
      );
    }

    return Positioned(
      left: leftPosition,
      child: Stack(
        clipBehavior: .none,
        alignment: .center,
        children: [
          thumbWidget,
          if (widget.showTooltip && isPressed)
            Positioned(top: -36.0, child: _buildTooltip(value, colors, theme)),
        ],
      ),
    );
  }

  Widget _buildTooltip(
    double value,
    JustColorScheme colors,
    JustThemeProviderState theme,
  ) {
    final valueText = value.toStringAsFixed(widget.divisions == null ? 1 : 0);
    final presetTokens = theme.theme.presetTokens;

    if (presetTokens.showsDefaultBorder) {
      return Container(
        padding: .symmetric(
          horizontal: theme.theme.spacing.xs,
          vertical: theme.theme.spacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: .all(theme.theme.radius.xs),
          border: .all(color: colors.textPrimary, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary,
              offset: const Offset(2.0, 2.0),
              blurRadius: 0.0,
            ),
          ],
        ),
        child: Text(
          valueText,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 12.0,
            fontWeight: .bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: .symmetric(
          horizontal: theme.theme.spacing.sm,
          vertical: theme.theme.spacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.textPrimary,
          borderRadius: .all(theme.theme.radius.sm),
        ),
        child: Text(
          valueText,
          style: TextStyle(
            color: colors.background,
            fontSize: 11.0,
            fontWeight: .w500,
          ),
        ),
      );
    }
  }

  void _handleDragStart(
    double localX,
    double startPosition,
    double endPosition,
    double thumbSize,
    double usableWidth,
    bool enableHaptic,
  ) {
    if (usableWidth <= 0) return;

    // Find the touch position fraction
    final touchFraction = (localX - thumbSize / 2) / usableWidth;
    final touchValue = widget.min + touchFraction * (widget.max - widget.min);

    if (_isRange) {
      // Determine which thumb is closer
      final distToStart = (touchValue - _currentStart).abs();
      final distToEnd = (touchValue - _currentEnd).abs();

      if (distToStart <= distToEnd) {
        _activeThumbIndex = 0;
      } else {
        _activeThumbIndex = 1;
      }
    } else {
      _activeThumbIndex = 0;
    }

    setState(() {});
    if (enableHaptic) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleDragUpdate(double localX, double usableWidth, bool enableHaptic) {
    if (_activeThumbIndex == -1 || usableWidth <= 0) return;

    final fraction = (localX / usableWidth).clamp(0.0, 1.0);
    double newValue = widget.min + fraction * (widget.max - widget.min);

    // Apply divisions snapping
    if (widget.divisions != null) {
      final step = (widget.max - widget.min) / widget.divisions!;
      final steps = ((newValue - widget.min) / step).round();
      newValue = (widget.min + steps * step).clamp(widget.min, widget.max);
    }

    if (_isRange) {
      if (_activeThumbIndex == 0) {
        // Dragging start thumb, clamp it below end thumb
        newValue = newValue.clamp(widget.min, _currentEnd);
        final updatedRange = JustRangeValues(newValue, _currentEnd);
        if (updatedRange != widget.rangeValues) {
          widget.onRangeChanged?.call(updatedRange);
          _triggerHapticIfNeeded(updatedRange, enableHaptic);
        }
      } else {
        // Dragging end thumb, clamp it above start thumb
        newValue = newValue.clamp(_currentStart, widget.max);
        final updatedRange = JustRangeValues(_currentStart, newValue);
        if (updatedRange != widget.rangeValues) {
          widget.onRangeChanged?.call(updatedRange);
          _triggerHapticIfNeeded(updatedRange, enableHaptic);
        }
      }
    } else {
      newValue = newValue.clamp(widget.min, widget.max);
      if (newValue != widget.value) {
        widget.onChanged?.call(newValue);
        _triggerHapticSingleSingleIfNeeded(newValue, enableHaptic);
      }
    }
  }

  void _handleDragEnd() {
    setState(() {
      _activeThumbIndex = -1;
    });
  }

  void _triggerHapticIfNeeded(JustRangeValues newValues, bool enableHaptic) {
    if (!enableHaptic) return;

    if (widget.divisions != null) {
      if (_lastHapticRangeValues == null ||
          _lastHapticRangeValues!.start != newValues.start ||
          _lastHapticRangeValues!.end != newValues.end) {
        HapticFeedback.selectionClick();
        _lastHapticRangeValues = newValues;
      }
    } else {
      // For continuous sliders, trigger haptics when hitting boundaries
      final hitBoundary =
          newValues.start == widget.min ||
          newValues.end == widget.max ||
          newValues.start == newValues.end;
      if (hitBoundary &&
          (_lastHapticRangeValues == null ||
              _lastHapticRangeValues != newValues)) {
        HapticFeedback.selectionClick();
        _lastHapticRangeValues = newValues;
      }
    }
  }

  void _triggerHapticSingleSingleIfNeeded(double newValue, bool enableHaptic) {
    if (!enableHaptic) return;

    if (widget.divisions != null) {
      if (_lastHapticValue == null || _lastHapticValue != newValue) {
        HapticFeedback.selectionClick();
        _lastHapticValue = newValue;
      }
    } else {
      // For continuous sliders, trigger haptics when hitting boundaries
      final hitBoundary = newValue == widget.min || newValue == widget.max;
      if (hitBoundary &&
          (_lastHapticValue == null || _lastHapticValue != newValue)) {
        HapticFeedback.selectionClick();
        _lastHapticValue = newValue;
      }
    }
  }
}

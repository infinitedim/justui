// justui-meta: registry=6e858d95edc45a41609cb5958fcca9100485d6c9026b640b636cad35dc3ea5db local=3138b6958f90fc6c1e5df9f868984725625cfac422008c9852ed89771fd94c50
import 'dart:async';

import 'package:flutter/material.dart' show DayPeriod, Theme, TimeOfDay;
import 'package:flutter/rendering.dart' show SemanticsService, TextDirection;
import 'package:flutter/services.dart'
    show HapticFeedback, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:showcase/core/just_ui_core.dart';

import '../shared/just_focus_indicator.dart';
import 'just_time_picker_style.dart';
import 'just_time_picker_theme.dart';
import 'just_time_picker_variants.dart';

/// A 3-column scrollable wheel time picker using [ListWheelScrollView].
///
/// Columns present hours, minutes, and (in 12-hour mode) an AM/PM period
/// selector with magnetic snapping via [FixedExtentScrollPhysics].
/// Features an overlay selection lens, WCAG 2.5.5 touch targets (minimum 44dp),
/// keyboard navigation support, and full semantic accessibility.
class TimePickerSpinner extends StatefulWidget {
  /// The currently selected time value.
  final TimeOfDay? value;

  /// Callback fired when the selected time changes.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Earliest selectable time (inclusive).
  final TimeOfDay? firstTime;

  /// Latest selectable time (inclusive).
  final TimeOfDay? lastTime;

  /// Predicate to selectively disable specific times.
  final bool Function(TimeOfDay)? selectableTimePredicate;

  /// Time format: 12-hour (with AM/PM column) or 24-hour.
  final JustTimeFormat timeFormat;

  /// Minute selection interval (e.g. 1, 5, 10, 15, 30). Must divide 60 evenly.
  final int minuteInterval;

  /// Initial active segment when focused.
  final JustTimePickerSegment initialSegment;

  /// Locale strings for labels, headers, and tooltips.
  final JustTimePickerLocale locale;

  /// Per-instance style overrides.
  final JustTimePickerStyle? style;

  /// Whether haptic feedback is triggered on value changes.
  /// When null, defaults to theme extension or preset token configuration.
  final bool? enableHaptic;

  /// Creates a [TimePickerSpinner] widget.
  const TimePickerSpinner({
    super.key,
    this.value,
    this.onChanged,
    this.firstTime,
    this.lastTime,
    this.selectableTimePredicate,
    this.timeFormat = .twelveHour,
    this.minuteInterval = 1,
    this.initialSegment = .hour,
    this.locale = const JustTimePickerLocale(),
    this.style,
    this.enableHaptic,
  }) : assert(60 % minuteInterval == 0, 'minuteInterval must evenly divide 60');

  /// Whether the picker is operating in 24-hour format.
  bool get is24Hour => timeFormat == .twentyFourHour;

  @override
  State<TimePickerSpinner> createState() => _TimePickerSpinnerState();
}

class _TimePickerSpinnerState extends State<TimePickerSpinner> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  late TimeOfDay _currentTime;
  late JustTimePickerSegment _focusedSegment;
  final FocusNode _focusNode = FocusNode();

  bool _isProgrammaticUpdate = false;
  int _lastHapticHour = -1;
  int _lastHapticMinute = -1;
  int _lastHapticPeriod = -1;
  Timer? _announceTimer;

  @override
  void initState() {
    super.initState();
    final TimeOfDay rawTime =
        widget.value ?? const TimeOfDay(hour: 12, minute: 0);
    _currentTime = _clampAndSnapTime(rawTime);
    _focusedSegment = widget.initialSegment;

    final int initialHourIndex = _calculateHourIndex(_currentTime);
    final int initialMinuteIndex = _calculateMinuteIndex(_currentTime);
    final int initialPeriodIndex = _calculatePeriodIndex(_currentTime);

    _hourController = FixedExtentScrollController(
      initialItem: initialHourIndex,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: initialMinuteIndex,
    );
    _periodController = FixedExtentScrollController(
      initialItem: initialPeriodIndex,
    );

    _lastHapticHour = initialHourIndex;
    _lastHapticMinute = initialMinuteIndex;
    _lastHapticPeriod = initialPeriodIndex;

    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant TimePickerSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null &&
        widget.value != _currentTime &&
        !_isProgrammaticUpdate) {
      final TimeOfDay clamped = _clampAndSnapTime(widget.value!);
      _currentTime = clamped;
      _syncControllers(clamped);
    }
  }

  @override
  void dispose() {
    _announceTimer?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  int _calculateHourIndex(TimeOfDay time) {
    if (widget.is24Hour) {
      return time.hour;
    }
    final int hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return hourOfPeriod - 1;
  }

  int _calculateMinuteIndex(TimeOfDay time) {
    return time.minute ~/ widget.minuteInterval;
  }

  int _calculatePeriodIndex(TimeOfDay time) {
    return time.period == DayPeriod.am ? 0 : 1;
  }

  TimeOfDay _clampAndSnapTime(TimeOfDay time) {
    TimeOfDay result = time.snapMinute(widget.minuteInterval);
    if (widget.firstTime != null &&
        result.totalMinutes < widget.firstTime!.totalMinutes) {
      result = widget.firstTime!.snapMinute(widget.minuteInterval);
    }
    if (widget.lastTime != null &&
        result.totalMinutes > widget.lastTime!.totalMinutes) {
      result = widget.lastTime!.snapMinute(widget.minuteInterval);
    }
    return result;
  }

  void _syncControllers(TimeOfDay time) {
    _isProgrammaticUpdate = true;
    try {
      final int targetHourIndex = _calculateHourIndex(time);
      final int hourCount = widget.is24Hour ? 24 : 12;
      if (_hourController.hasClients) {
        final int current = _hourController.selectedItem;
        final int currentNorm = ((current % hourCount) + hourCount) % hourCount;
        final int diff = targetHourIndex - currentNorm;
        _hourController.jumpToItem(current + diff);
      }

      final int targetMinuteIndex = _calculateMinuteIndex(time);
      final int minuteCount = 60 ~/ widget.minuteInterval;
      if (_minuteController.hasClients) {
        final int current = _minuteController.selectedItem;
        final int currentNorm =
            ((current % minuteCount) + minuteCount) % minuteCount;
        final int diff = targetMinuteIndex - currentNorm;
        _minuteController.jumpToItem(current + diff);
      }

      if (!widget.is24Hour && _periodController.hasClients) {
        final int targetPeriod = _calculatePeriodIndex(time);
        _periodController.jumpToItem(targetPeriod);
      }
    } finally {
      _isProgrammaticUpdate = false;
    }
  }

  void _onHourChanged(int rawIndex) {
    if (_isProgrammaticUpdate) return;
    final int hourCount = widget.is24Hour ? 24 : 12;
    final int normIndex = ((rawIndex % hourCount) + hourCount) % hourCount;

    int newHour24;
    if (widget.is24Hour) {
      newHour24 = normIndex;
    } else {
      final int hour12 = normIndex + 1;
      final bool isAm = _currentTime.period == DayPeriod.am;
      newHour24 = isAm
          ? (hour12 == 12 ? 0 : hour12)
          : (hour12 == 12 ? 12 : hour12 + 12);
    }

    if (normIndex != _lastHapticHour) {
      _lastHapticHour = normIndex;
      _triggerHaptic();
    }

    final TimeOfDay newTime = TimeOfDay(
      hour: newHour24,
      minute: _currentTime.minute,
    );
    _updateTime(newTime);
  }

  void _onMinuteChanged(int rawIndex) {
    if (_isProgrammaticUpdate) return;
    final int minuteCount = 60 ~/ widget.minuteInterval;
    final int normIndex =
        ((rawIndex % minuteCount) + minuteCount) % minuteCount;
    final int newMinute = normIndex * widget.minuteInterval;

    if (normIndex != _lastHapticMinute) {
      _lastHapticMinute = normIndex;
      _triggerHaptic();
    }

    final TimeOfDay newTime = TimeOfDay(
      hour: _currentTime.hour,
      minute: newMinute,
    );
    _updateTime(newTime);
  }

  void _onPeriodChanged(int rawIndex) {
    if (_isProgrammaticUpdate) return;
    final int periodIndex = rawIndex.clamp(0, 1);
    final bool isAm = periodIndex == 0;

    if (periodIndex != _lastHapticPeriod) {
      _lastHapticPeriod = periodIndex;
      _triggerHaptic();
    }

    final int hour12 = _currentTime.hourOfPeriod == 0
        ? 12
        : _currentTime.hourOfPeriod;
    final int newHour24 = isAm
        ? (hour12 == 12 ? 0 : hour12)
        : (hour12 == 12 ? 12 : hour12 + 12);

    final TimeOfDay newTime = TimeOfDay(
      hour: newHour24,
      minute: _currentTime.minute,
    );
    _updateTime(newTime);
  }

  void _updateTime(TimeOfDay newTime) {
    setState(() {
      _currentTime = newTime;
    });
    widget.onChanged?.call(newTime);
    _announceTimeChange(newTime);
  }

  bool _isTimeAllowed(TimeOfDay time) {
    if (widget.firstTime != null &&
        time.totalMinutes < widget.firstTime!.totalMinutes) {
      return false;
    }
    if (widget.lastTime != null &&
        time.totalMinutes > widget.lastTime!.totalMinutes) {
      return false;
    }
    if (widget.selectableTimePredicate != null &&
        !widget.selectableTimePredicate!(time)) {
      return false;
    }
    return true;
  }

  bool _isHourAllowed(int hour24) {
    final int minuteInterval = widget.minuteInterval;
    for (int m = 0; m < 60; m += minuteInterval) {
      final TimeOfDay time = TimeOfDay(hour: hour24, minute: m);
      if (_isTimeAllowed(time)) return true;
    }
    return false;
  }

  bool _isMinuteAllowed(int minute) {
    final TimeOfDay time = TimeOfDay(hour: _currentTime.hour, minute: minute);
    return _isTimeAllowed(time);
  }

  bool _isPeriodAllowed(DayPeriod period) {
    final int hour12 = _currentTime.hourOfPeriod == 0
        ? 12
        : _currentTime.hourOfPeriod;
    final int hour24 = period == DayPeriod.am
        ? (hour12 == 12 ? 0 : hour12)
        : (hour12 == 12 ? 12 : hour12 + 12);
    return _isHourAllowed(hour24);
  }

  void _announceTimeChange(TimeOfDay time) {
    _announceTimer?.cancel();
    _announceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      SemanticsService.sendAnnouncement(
        View.of(context),
        time.format(context),
        TextDirection.ltr,
      );
    });
  }

  void _triggerHaptic() {
    final JustThemeData theme = JustThemeProvider.of(context).theme;
    final JustTimePickerTheme? themeExtension = Theme.of(context)
        .extension<JustTimePickerTheme>();
    final bool shouldHaptic =
        widget.enableHaptic ??
        themeExtension?.enableHaptic ??
        theme.presetTokens.selectionHapticDefault;
    if (shouldHaptic) {
      HapticFeedback.selectionClick();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;

    final LogicalKeyboardKey key = event.logicalKey;
    if (key == .arrowLeft) {
      setState(() {
        if (_focusedSegment == .period) {
          _focusedSegment = .minute;
        } else if (_focusedSegment == .minute) {
          _focusedSegment = .hour;
        }
      });
      return .handled;
    }

    if (key == .arrowRight) {
      setState(() {
        if (_focusedSegment == .hour) {
          _focusedSegment = .minute;
        } else if (_focusedSegment == .minute && !widget.is24Hour) {
          _focusedSegment = .period;
        }
      });
      return .handled;
    }

    if (key == .arrowUp) {
      switch (_focusedSegment) {
        case .hour:
          _scrollHourUp();
        case .minute:
          _scrollMinuteUp();
        case .period:
          _animatePeriodTo(0);
      }
      return .handled;
    }

    if (key == .arrowDown) {
      switch (_focusedSegment) {
        case .hour:
          _scrollHourDown();
        case .minute:
          _scrollMinuteDown();
        case .period:
          _animatePeriodTo(1);
      }
      return .handled;
    }

    if (key == .pageUp) {
      _scrollHourUp();
      return .handled;
    }

    if (key == .pageDown) {
      _scrollHourDown();
      return .handled;
    }

    if (key == .home) {
      final TimeOfDay target =
          widget.firstTime ?? const TimeOfDay(hour: 0, minute: 0);
      _updateTime(target);
      _syncControllers(target);
      return .handled;
    }

    if (key == .end) {
      final TimeOfDay target =
          (widget.lastTime ?? const TimeOfDay(hour: 23, minute: 59)).snapMinute(
            widget.minuteInterval,
          );
      _updateTime(target);
      _syncControllers(target);
      return .handled;
    }

    if ((key == .enter || key == .space) && _focusedSegment == .period) {
      _togglePeriod();
      return .handled;
    }

    return .ignored;
  }

  void _animateWheelToItem(
    FixedExtentScrollController controller,
    int targetIndex,
    int itemCount, {
    bool isLooping = true,
  }) {
    if (!controller.hasClients) return;
    if (!isLooping) {
      controller.animateToItem(
        targetIndex.clamp(0, itemCount - 1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final int current = controller.selectedItem;
    final int currentNorm = ((current % itemCount) + itemCount) % itemCount;
    int diff = targetIndex - currentNorm;

    if (diff > itemCount / 2) {
      diff -= itemCount;
    } else if (diff < -itemCount / 2) {
      diff += itemCount;
    }

    controller.animateToItem(
      current + diff,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollHourUp() {
    if (_hourController.hasClients) {
      _hourController.animateToItem(
        _hourController.selectedItem - 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollHourDown() {
    if (_hourController.hasClients) {
      _hourController.animateToItem(
        _hourController.selectedItem + 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollMinuteUp() {
    if (_minuteController.hasClients) {
      _minuteController.animateToItem(
        _minuteController.selectedItem - 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollMinuteDown() {
    if (_minuteController.hasClients) {
      _minuteController.animateToItem(
        _minuteController.selectedItem + 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _animatePeriodTo(int index) {
    if (!widget.is24Hour && _periodController.hasClients) {
      _periodController.animateToItem(
        index.clamp(0, 1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _togglePeriod() {
    final int nextIndex = _currentTime.period == DayPeriod.am ? 1 : 0;
    _animatePeriodTo(nextIndex);
  }

  String _formatCurrentHour() {
    if (widget.is24Hour) {
      return _currentTime.hour.toString().padLeft(2, '0');
    }
    final int h = _currentTime.hourOfPeriod == 0
        ? 12
        : _currentTime.hourOfPeriod;
    return h.toString().padLeft(2, '0');
  }

  String _nextHourLabel() {
    if (widget.is24Hour) {
      return ((_currentTime.hour + 1) % 24).toString().padLeft(2, '0');
    }
    final int current12 = _currentTime.hourOfPeriod == 0
        ? 12
        : _currentTime.hourOfPeriod;
    final int next12 = (current12 % 12) + 1;
    return next12.toString().padLeft(2, '0');
  }

  String _prevHourLabel() {
    if (widget.is24Hour) {
      return ((_currentTime.hour + 23) % 24).toString().padLeft(2, '0');
    }
    final int current12 = _currentTime.hourOfPeriod == 0
        ? 12
        : _currentTime.hourOfPeriod;
    final int prev12 = current12 <= 1 ? 12 : current12 - 1;
    return prev12.toString().padLeft(2, '0');
  }

  String _nextMinuteLabel() {
    final int count = 60 ~/ widget.minuteInterval;
    final int currentIdx = _currentTime.minute ~/ widget.minuteInterval;
    final int nextIdx = (currentIdx + 1) % count;
    return (nextIdx * widget.minuteInterval).toString().padLeft(2, '0');
  }

  String _prevMinuteLabel() {
    final int count = 60 ~/ widget.minuteInterval;
    final int currentIdx = _currentTime.minute ~/ widget.minuteInterval;
    final int prevIdx = (currentIdx - 1 + count) % count;
    return (prevIdx * widget.minuteInterval).toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final JustColorScheme colors = context.justColors;
    final JustTypographyScheme typo = context.justTypo;
    final JustSpacingScheme spacing = context.justSpacing;
    final JustRadiusScheme radius = context.justRadius;
    final JustThemeData theme = JustThemeProvider.of(context).theme;
    final JustPresetTokens presetTokens = theme.presetTokens;

    final JustTimePickerTheme? themeExtension = Theme.of(context)
        .extension<JustTimePickerTheme>();
    final JustTimePickerStyle? style = widget.style;

    final Color bgColor =
        style?.backgroundColor ??
        themeExtension?.inlineStyle?.backgroundColor ??
        colors.card;
    final Color borderColor =
        style?.borderColor ??
        themeExtension?.inlineStyle?.borderColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault);
    final BorderRadius borderRadius =
        style?.borderRadius ??
        themeExtension?.inlineStyle?.borderRadius ??
        presetTokens.resolveBorderRadius(radius);
    final EdgeInsets padding =
        style?.padding ??
        themeExtension?.inlineStyle?.padding ??
        .symmetric(horizontal: spacing.md, vertical: spacing.sm);
    final double borderWidth = presetTokens.borderWidth;
    final double rowHeight = style?.spinnerRowHeight ?? 44.0;
    final double spinnerHeight = rowHeight * 5;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: FocusIndicator(
        isFocused: _focusNode.hasFocus,
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: presetTokens.showsDefaultBorder
                ? .all(color: borderColor, width: borderWidth)
                : (borderWidth > 0
                      ? .all(color: colors.borderDefault, width: borderWidth)
                      : null),
            boxShadow: presetTokens.resolveShadow(
              theme.shadows,
              .md,
              isPressed: false,
            ),
          ),
          child: SizedBox(
            height: spinnerHeight,
            child: Stack(
              children: <Widget>[
                // Selection Highlight Lens Overlay (IgnorePointer)
                Positioned(
                  left: 0,
                  right: 0,
                  top: (spinnerHeight - rowHeight) / 2,
                  height: rowHeight,
                  child: IgnorePointer(
                    child: Container(
                      margin: .symmetric(horizontal: spacing.xs),
                      decoration: BoxDecoration(
                        color: (style?.periodActiveColor ?? colors.borderFocus)
                            .withValues(alpha: 0.08),
                        borderRadius: presetTokens.resolveBorderRadius(radius),
                        border: .all(
                          color: colors.borderFocus,
                          width: presetTokens.showsDefaultBorder
                              ? presetTokens.borderWidth
                              : 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // 3 Columns: Hour, Colon, Minute, (optional) Period
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: .center,
                    children: <Widget>[
                      Expanded(
                        child: _buildHourWheel(
                          itemExtent: rowHeight,
                          colors: colors,
                          typo: typo,
                          locale: widget.locale,
                        ),
                      ),
                      _buildColonSeparator(colors: colors, typo: typo),
                      Expanded(
                        child: _buildMinuteWheel(
                          itemExtent: rowHeight,
                          colors: colors,
                          typo: typo,
                          locale: widget.locale,
                        ),
                      ),
                      if (!widget.is24Hour) ...<Widget>[
                        SizedBox(width: spacing.xs),
                        Expanded(
                          child: _buildPeriodWheel(
                            itemExtent: rowHeight,
                            colors: colors,
                            typo: typo,
                            locale: widget.locale,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourWheel({
    required double itemExtent,
    required JustColorScheme colors,
    required JustTypographyScheme typo,
    required JustTimePickerLocale locale,
  }) {
    final int hourCount = widget.is24Hour ? 24 : 12;
    return Semantics(
      container: true,
      label: locale.hourLabel,
      value: _formatCurrentHour(),
      increasedValue: _nextHourLabel(),
      decreasedValue: _prevHourLabel(),
      onIncrease: _scrollHourDown,
      onDecrease: _scrollHourUp,
      child: ListWheelScrollView.useDelegate(
        controller: _hourController,
        physics: const FixedExtentScrollPhysics(),
        itemExtent: itemExtent,
        diameterRatio: 2.0,
        perspective: 0.003,
        offAxisFraction: -0.15,
        magnification: 1.12,
        overAndUnderCenterOpacity: 0.4,
        squeeze: 1.0,
        onSelectedItemChanged: _onHourChanged,
        childDelegate: ListWheelChildLoopingListDelegate(
          children: .generate(hourCount, (int i) {
            final int displayHour = widget.is24Hour ? i : i + 1;
            final int hour24 = widget.is24Hour
                ? i
                : (_currentTime.period == DayPeriod.am
                      ? (displayHour == 12 ? 0 : displayHour)
                      : (displayHour == 12 ? 12 : displayHour + 12));
            final bool isSelected = widget.is24Hour
                ? displayHour == _currentTime.hour
                : displayHour ==
                      (_currentTime.hourOfPeriod == 0
                          ? 12
                          : _currentTime.hourOfPeriod);
            final bool isAllowed = _isHourAllowed(hour24);

            return _buildWheelItem(
              text: displayHour.toString().padLeft(2, '0'),
              isSelected: isSelected,
              isDisabled: !isAllowed,
              colors: colors,
              typo: typo,
              itemExtent: itemExtent,
              onTap: () => _animateWheelToItem(_hourController, i, hourCount),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMinuteWheel({
    required double itemExtent,
    required JustColorScheme colors,
    required JustTypographyScheme typo,
    required JustTimePickerLocale locale,
  }) {
    final int minuteCount = 60 ~/ widget.minuteInterval;
    return Semantics(
      container: true,
      label: locale.minuteLabel,
      value: _currentTime.minute.toString().padLeft(2, '0'),
      increasedValue: _nextMinuteLabel(),
      decreasedValue: _prevMinuteLabel(),
      onIncrease: _scrollMinuteDown,
      onDecrease: _scrollMinuteUp,
      child: ListWheelScrollView.useDelegate(
        controller: _minuteController,
        physics: const FixedExtentScrollPhysics(),
        itemExtent: itemExtent,
        diameterRatio: 2.0,
        perspective: 0.003,
        offAxisFraction: 0.0,
        magnification: 1.12,
        overAndUnderCenterOpacity: 0.4,
        squeeze: 1.0,
        onSelectedItemChanged: _onMinuteChanged,
        childDelegate: ListWheelChildLoopingListDelegate(
          children: .generate(minuteCount, (int i) {
            final int minute = i * widget.minuteInterval;
            final bool isSelected = _currentTime.minute == minute;
            final bool isAllowed = _isMinuteAllowed(minute);

            return _buildWheelItem(
              text: minute.toString().padLeft(2, '0'),
              isSelected: isSelected,
              isDisabled: !isAllowed,
              colors: colors,
              typo: typo,
              itemExtent: itemExtent,
              onTap: () =>
                  _animateWheelToItem(_minuteController, i, minuteCount),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPeriodWheel({
    required double itemExtent,
    required JustColorScheme colors,
    required JustTypographyScheme typo,
    required JustTimePickerLocale locale,
  }) {
    final bool isAm = _currentTime.period == DayPeriod.am;
    return Semantics(
      container: true,
      label: locale.periodLabel,
      value: isAm ? locale.amLabel : locale.pmLabel,
      increasedValue: isAm ? locale.pmLabel : locale.amLabel,
      decreasedValue: isAm ? locale.pmLabel : locale.amLabel,
      onIncrease: () => _animatePeriodTo(1),
      onDecrease: () => _animatePeriodTo(0),
      child: ListWheelScrollView.useDelegate(
        controller: _periodController,
        physics: const FixedExtentScrollPhysics(),
        itemExtent: itemExtent,
        diameterRatio: 2.0,
        perspective: 0.003,
        offAxisFraction: 0.15,
        magnification: 1.12,
        overAndUnderCenterOpacity: 0.4,
        squeeze: 1.0,
        onSelectedItemChanged: _onPeriodChanged,
        childDelegate: ListWheelChildListDelegate(
          children: <Widget>[
            _buildWheelItem(
              text: locale.amLabel,
              isSelected: isAm,
              isDisabled: !_isPeriodAllowed(DayPeriod.am),
              colors: colors,
              typo: typo,
              itemExtent: itemExtent,
              onTap: () => _animatePeriodTo(0),
            ),
            _buildWheelItem(
              text: locale.pmLabel,
              isSelected: !isAm,
              isDisabled: !_isPeriodAllowed(DayPeriod.pm),
              colors: colors,
              typo: typo,
              itemExtent: itemExtent,
              onTap: () => _animatePeriodTo(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelItem({
    required String text,
    required bool isSelected,
    required bool isDisabled,
    required JustColorScheme colors,
    required JustTypographyScheme typo,
    required double itemExtent,
    VoidCallback? onTap,
  }) {
    final Color selectedColor =
        widget.style?.selectedTextColor ?? colors.textPrimary;
    final Color unselectedColor =
        widget.style?.dialTextColor ?? colors.textSecondary;

    final Color color = isDisabled
        ? colors.textDisabled.withValues(alpha: 0.38)
        : (isSelected ? selectedColor : unselectedColor);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: itemExtent,
        alignment: .center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style: typo.headingSm.copyWith(
            color: color,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
          textAlign: .center,
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildColonSeparator({
    required JustColorScheme colors,
    required JustTypographyScheme typo,
  }) {
    return ExcludeSemantics(
      child: Padding(
        padding: const .symmetric(horizontal: 4.0),
        child: Center(
          child: Text(
            ':',
            style: typo.headingLg.copyWith(
              color: widget.style?.dialTextColor ?? colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

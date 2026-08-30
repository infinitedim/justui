import 'dart:async' show Timer;
import 'dart:math' as math;

import 'package:flutter/material.dart' show Theme, TimeOfDay;
import 'package:flutter/rendering.dart' show SemanticsService, TextDirection;
import 'package:flutter/services.dart'
    show
        HapticFeedback,
        KeyDownEvent,
        KeyEvent,
        LogicalKeyboardKey,
        PhysicalKeyboardKey,
        SystemMouseCursors;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import '../shared/_shared_focus_indicator.dart';
import 'just_time_picker_style.dart';
import 'just_time_picker_theme.dart';
import 'just_time_picker_variants.dart';

/// Interactive circular clock face dial for [JustTimePicker].
///
/// Features a two-layer [RepaintBoundary] architecture, smooth shortest-arc
/// hand animations, dual concentric rings in 24-hour mode, responsive drag
/// gestures with atan2 angle resolution, and WCAG-compliant keyboard and
/// screen reader accessibility.
class TimePickerDial extends StatefulWidget {
  /// Currently selected time value.
  final TimeOfDay? selectedTime;

  /// Callback fired when the selected time changes.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Earliest selectable time (inclusive).
  final TimeOfDay? firstTime;

  /// Latest selectable time (inclusive).
  final TimeOfDay? lastTime;

  /// Predicate to selectively disable specific times.
  final bool Function(TimeOfDay)? selectableTimePredicate;

  /// Time format (12-hour or 24-hour).
  final JustTimeFormat timeFormat;

  /// Minute selection interval (e.g. 1, 5, 10, 15, 30).
  final int minuteInterval;

  /// Currently active segment (hour or minute).
  final JustTimePickerSegment activeSegment;

  /// Callback when segment changes (e.g. auto-advance from hour to minute).
  final ValueChanged<JustTimePickerSegment>? onSegmentChanged;

  /// Whether selecting an hour automatically advances to minute selection.
  final bool autoAdvance;

  /// Locale strings for semantic announcements and tooltips.
  final JustTimePickerLocale locale;

  /// Per-instance style overrides.
  final JustTimePickerStyle? style;

  /// Whether haptic feedback is enabled.
  final bool? enableHaptic;

  /// Creates a [TimePickerDial] widget.
  const TimePickerDial({
    super.key,
    this.selectedTime,
    this.onChanged,
    this.firstTime,
    this.lastTime,
    this.selectableTimePredicate,
    this.timeFormat = .twelveHour,
    this.minuteInterval = 1,
    this.activeSegment = .hour,
    this.onSegmentChanged,
    this.autoAdvance = true,
    this.locale = const JustTimePickerLocale(),
    this.style,
    this.enableHaptic,
  });

  @override
  State<TimePickerDial> createState() => _TimePickerDialState();
}

class _TimePickerDialState extends State<TimePickerDial>
    with SingleTickerProviderStateMixin {
  late JustTimePickerSegment _activeSegment;
  late TimeOfDay _currentTime;
  late double _currentAngle;
  late double _currentRadius;
  bool _isDragging = false;
  int? _lastHapticValue;
  Offset _lastTouchPosition = .zero;

  late final AnimationController _handController;
  double _startAngle = 0.0;
  double _deltaAngle = 0.0;
  double _startRadius = 0.0;
  double _targetAngle = -1.0;
  double _targetRadius = 0.0;

  Timer? _autoAdvanceTimer;
  Timer? _announceTimer;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _activeSegment = widget.activeSegment;
    _currentTime = widget.selectedTime ?? const TimeOfDay(hour: 12, minute: 0);
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(_onAnimationTick);

    _focusNode.addListener(_onFocusChange);

    _currentAngle = _angleForTime(
      _currentTime,
      _activeSegment,
      widget.timeFormat,
    );
    _targetAngle = _currentAngle;
    _currentRadius = _radiusForTime(
      _currentTime,
      _activeSegment,
      widget.timeFormat,
      _resolveOuterRadius(240.0),
      _resolveInnerRadius(240.0),
    );
    _targetRadius = _currentRadius;
  }

  @override
  void didUpdateWidget(covariant TimePickerDial oldWidget) {
    super.didUpdateWidget(oldWidget);

    final size = widget.style?.dialSize ?? 240.0;
    final outerR = _resolveOuterRadius(size);
    final innerR = _resolveInnerRadius(size);

    if (widget.selectedTime != null &&
        widget.selectedTime != _currentTime &&
        !_isDragging) {
      _currentTime = widget.selectedTime!;
      final targetAngle = _angleForTime(
        _currentTime,
        _activeSegment,
        widget.timeFormat,
      );
      final targetRadius = _radiusForTime(
        _currentTime,
        _activeSegment,
        widget.timeFormat,
        outerR,
        innerR,
      );
      _animateHandTo(targetAngle, targetRadius);
    } else if (widget.activeSegment != oldWidget.activeSegment) {
      _activeSegment = widget.activeSegment;
      final targetAngle = _angleForTime(
        _currentTime,
        _activeSegment,
        widget.timeFormat,
      );
      final targetRadius = _radiusForTime(
        _currentTime,
        _activeSegment,
        widget.timeFormat,
        outerR,
        innerR,
      );
      _animateHandTo(targetAngle, targetRadius);
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _announceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _handController.removeListener(_onAnimationTick);
    _handController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _onAnimationTick() {
    setState(() {
      final curve = Curves.easeOutCubic.transform(_handController.value);
      _currentAngle = _startAngle + _deltaAngle * curve;
      _currentRadius = _startRadius + (_targetRadius - _startRadius) * curve;
    });
  }

  double _resolveOuterRadius(double dialSize) => (dialSize / 2) - 24.0;
  double _resolveInnerRadius(double dialSize) =>
      _resolveOuterRadius(dialSize) * 0.68;

  double _angleForTime(
    TimeOfDay time,
    JustTimePickerSegment segment,
    JustTimeFormat format,
  ) {
    if (segment == .hour) {
      if (format == .twentyFourHour) {
        final sector = time.hour % 12;
        return (sector * 2 * math.pi) / 12;
      } else {
        final h12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        return (h12 % 12) * (2 * math.pi) / 12;
      }
    } else {
      return (time.minute * 2 * math.pi) / 60;
    }
  }

  double _radiusForTime(
    TimeOfDay time,
    JustTimePickerSegment segment,
    JustTimeFormat format,
    double outerR,
    double innerR,
  ) {
    if (segment == .hour && format == .twentyFourHour) {
      if (time.hour == 0 || time.hour >= 13) {
        return innerR;
      }
    }
    return outerR;
  }

  void _animateHandTo(
    double targetAngle,
    double targetRadius, {
    Duration duration = const Duration(milliseconds: 200),
  }) {
    _handController.stop();
    _startAngle = _currentAngle;
    _targetAngle = targetAngle;
    // Shortest angular delta: (target - start + pi) % (2pi) - pi
    _deltaAngle =
        (targetAngle - _startAngle + math.pi) % (2 * math.pi) - math.pi;
    _startRadius = _currentRadius;
    _targetRadius = targetRadius;

    _handController.duration = duration;
    _handController.forward(from: 0.0);
  }

  bool _isTimeAllowed(TimeOfDay time) {
    if (!time.isWithin(widget.firstTime, widget.lastTime)) {
      return false;
    }
    if (widget.selectableTimePredicate != null &&
        !widget.selectableTimePredicate!(time)) {
      return false;
    }
    return true;
  }

  void _triggerHaptic() {
    final theme = context.justTheme;
    final timePickerTheme = Theme.of(context).extension<JustTimePickerTheme>();
    final isHapticEnabled =
        widget.enableHaptic ??
        timePickerTheme?.enableHaptic ??
        theme.presetTokens.selectionHapticDefault;

    if (isHapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void _announceTime(TimeOfDay time) {
    _announceTimer?.cancel();
    _announceTimer = Timer(const Duration(milliseconds: 300), () {
      final periodStr = time.period == .am
          ? widget.locale.amLabel
          : widget.locale.pmLabel;
      final hourStr = widget.timeFormat == .twentyFourHour
          ? time.hour.toString().padLeft(2, '0')
          : (time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod).toString();
      final minuteStr = time.minute.toString().padLeft(2, '0');
      final message = widget.timeFormat == .twentyFourHour
          ? '$hourStr:$minuteStr'
          : '$hourStr:$minuteStr $periodStr';
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        TextDirection.ltr,
      );
    });
  }

  void _scheduleAutoAdvance(int selectedHour) {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted || _isDragging) return;
      setState(() {
        _activeSegment = .minute;
        final time =
            widget.selectedTime ?? const TimeOfDay(hour: 12, minute: 0);
        final size = widget.style?.dialSize ?? 240.0;
        final outerR = _resolveOuterRadius(size);
        final innerR = _resolveInnerRadius(size);
        final targetAngle = _angleForTime(time, .minute, widget.timeFormat);
        final targetRadius = _radiusForTime(
          time,
          .minute,
          widget.timeFormat,
          outerR,
          innerR,
        );
        _animateHandTo(targetAngle, targetRadius);
      });
      widget.onSegmentChanged?.call(.minute);
      SemanticsService.sendAnnouncement(
        View.of(context),
        '${widget.locale.hourLabel} $selectedHour selected. Now select ${widget.locale.minuteLabel.toLowerCase()}s.',
        TextDirection.ltr,
      );
    });
  }

  void _handleTouch(Offset localPosition, Size size, {required bool isFinal}) {
    _lastTouchPosition = localPosition;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final r = math.sqrt(dx * dx + dy * dy);

    // atan2(dy, dx) returns angle from +X axis clockwise
    final rawTheta = math.atan2(dy, dx);
    final clockTheta = rawTheta + (math.pi / 2);
    final theta = (clockTheta % (2 * math.pi) + (2 * math.pi)) % (2 * math.pi);

    final outerR = _resolveOuterRadius(size.width);
    final innerR = _resolveInnerRadius(size.width);
    final thresholdR = (outerR + innerR) / 2;

    final currentTime = _currentTime;
    TimeOfDay newTime;
    double targetAngle;
    double targetRadius;
    int hapticVal;
    int? justSelectedHour;

    if (_activeSegment == .hour) {
      if (widget.timeFormat == .twentyFourHour) {
        final sector = ((theta * 12) / (2 * math.pi)).round() % 12;
        final base12 = sector == 0 ? 12 : sector;
        final isInner = r < thresholdR;
        final hour24 = isInner ? (base12 == 12 ? 0 : base12 + 12) : base12;
        newTime = currentTime.replacing(hour: hour24);
        targetAngle = (sector * 2 * math.pi) / 12;
        targetRadius = isInner ? innerR : outerR;
        hapticVal = hour24;
        justSelectedHour = hour24;
      } else {
        final sector = ((theta * 12) / (2 * math.pi)).round() % 12;
        final hour12 = sector == 0 ? 12 : sector;
        final period = currentTime.period;
        newTime = currentTime.withHour12(hour12, period);
        targetAngle = (sector * 2 * math.pi) / 12;
        targetRadius = outerR;
        hapticVal = hour12;
        justSelectedHour = hour12;
      }
    } else {
      final stepCount = 60 ~/ widget.minuteInterval;
      final stepIndex =
          ((theta * stepCount) / (2 * math.pi)).round() % stepCount;
      final minute = (stepIndex * widget.minuteInterval) % 60;
      newTime = currentTime.replacing(minute: minute);
      targetAngle = (minute * 2 * math.pi) / 60;
      targetRadius = outerR;
      hapticVal = minute;
    }

    if (!_isTimeAllowed(newTime)) {
      return;
    }

    if (hapticVal != _lastHapticValue) {
      _lastHapticValue = hapticVal;
      _triggerHaptic();
    }

    if (isFinal) {
      _isDragging = false;
      setState(() {
        _currentTime = newTime;
      });
      _animateHandTo(
        targetAngle,
        targetRadius,
        duration: const Duration(milliseconds: 200),
      );
      widget.onChanged?.call(newTime);
      _announceTime(newTime);

      if (_activeSegment == .hour &&
          widget.autoAdvance &&
          justSelectedHour != null) {
        _scheduleAutoAdvance(justSelectedHour);
      }
    } else {
      _autoAdvanceTimer?.cancel();
      _isDragging = true;
      setState(() {
        _currentTime = newTime;
      });
      if (targetAngle != _targetAngle || targetRadius != _targetRadius) {
        _animateHandTo(
          targetAngle,
          targetRadius,
          duration: const Duration(milliseconds: 120),
        );
      } else if (!_handController.isAnimating) {
        setState(() {
          _currentAngle = targetAngle;
          _currentRadius = targetRadius;
        });
      }
      widget.onChanged?.call(newTime);
      _announceTime(newTime);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;

    final currentTime =
        widget.selectedTime ?? const TimeOfDay(hour: 12, minute: 0);
    final size = widget.style?.dialSize ?? 240.0;
    final outerR = _resolveOuterRadius(size);
    final innerR = _resolveInnerRadius(size);

    TimeOfDay? nextTime;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_activeSegment == .hour) {
        final newHour = (currentTime.hour + 1) % 24;
        nextTime = currentTime.replacing(hour: newHour);
      } else {
        final snapped =
            ((currentTime.minute ~/ widget.minuteInterval) + 1) *
            widget.minuteInterval;
        nextTime = currentTime.replacing(minute: snapped % 60);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_activeSegment == .hour) {
        final newHour = (currentTime.hour - 1 + 24) % 24;
        nextTime = currentTime.replacing(hour: newHour);
      } else {
        final currentSteps = currentTime.minute ~/ widget.minuteInterval;
        final snapped =
            (currentSteps - 1 + (60 ~/ widget.minuteInterval)) *
            widget.minuteInterval;
        nextTime = currentTime.replacing(minute: snapped % 60);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      final newHour = (currentTime.hour + 1) % 24;
      nextTime = currentTime.replacing(hour: newHour);
    } else if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      final newHour = (currentTime.hour - 1 + 24) % 24;
      nextTime = currentTime.replacing(hour: newHour);
    } else if (event.logicalKey == LogicalKeyboardKey.home) {
      nextTime = widget.firstTime ?? const TimeOfDay(hour: 0, minute: 0);
    } else if (event.logicalKey == LogicalKeyboardKey.end) {
      nextTime = widget.lastTime ?? const TimeOfDay(hour: 23, minute: 59);
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (_activeSegment == .hour) {
        setState(() {
          _activeSegment = .minute;
          final targetAngle = _angleForTime(
            currentTime,
            .minute,
            widget.timeFormat,
          );
          final targetRadius = _radiusForTime(
            currentTime,
            .minute,
            widget.timeFormat,
            outerR,
            innerR,
          );
          _animateHandTo(targetAngle, targetRadius);
        });
        widget.onSegmentChanged?.call(.minute);
        return .handled;
      }
    }

    if (nextTime != null && _isTimeAllowed(nextTime)) {
      _triggerHaptic();
      widget.onChanged?.call(nextTime);
      final targetAngle = _angleForTime(
        nextTime,
        _activeSegment,
        widget.timeFormat,
      );
      final targetRadius = _radiusForTime(
        nextTime,
        _activeSegment,
        widget.timeFormat,
        outerR,
        innerR,
      );
      _animateHandTo(targetAngle, targetRadius);
      _announceTime(nextTime);
      return .handled;
    }

    return .ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.justTheme;
    final colors = context.justColors;
    final typo = context.justTypo;
    final presetTokens = theme.presetTokens;

    final dialSize =
        widget.style?.dialSize ?? presetTokens.resolveTimePickerDialSize();
    final time = widget.selectedTime ?? const TimeOfDay(hour: 12, minute: 0);
    final dialFaceColor = widget.style?.dialFaceColor ?? colors.muted;
    final handColor = widget.style?.handColor ?? colors.borderFocus;
    final dialTextColor = widget.style?.dialTextColor ?? colors.textPrimary;
    final selectedTextColor =
        widget.style?.selectedTextColor ?? colors.textInverse;
    final borderColor =
        widget.style?.borderColor ??
        (presetTokens.showsDefaultBorder
            ? colors.borderDefault
            : colors.borderDefault);

    final selectedValueLabel = _activeSegment == .hour
        ? (widget.timeFormat == .twentyFourHour
              ? time.hour.toString().padLeft(2, '0')
              : (time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod).toString())
        : time.minute.toString().padLeft(2, '0');

    final outerR = _resolveOuterRadius(dialSize);
    final innerR = _resolveInnerRadius(dialSize);

    return FocusIndicator(
      isFocused: _isFocused,
      borderRadius: .circular(dialSize / 2),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Semantics(
          container: true,
          label: _activeSegment == .hour
              ? widget.locale.hourLabel
              : widget.locale.minuteLabel,
          value: selectedValueLabel,
          increasedValue: 'Next value',
          decreasedValue: 'Previous value',
          onIncrease: () => _handleKeyEvent(
            _focusNode,
            const KeyDownEvent(
              logicalKey: LogicalKeyboardKey.arrowUp,
              physicalKey: PhysicalKeyboardKey.arrowUp,
              timeStamp: .zero,
            ),
          ),
          onDecrease: () => _handleKeyEvent(
            _focusNode,
            const KeyDownEvent(
              logicalKey: LogicalKeyboardKey.arrowDown,
              physicalKey: PhysicalKeyboardKey.arrowDown,
              timeStamp: .zero,
            ),
          ),
          child: GestureDetector(
            behavior: .opaque,
            onPanStart: (d) => _handleTouch(
              d.localPosition,
              Size(dialSize, dialSize),
              isFinal: false,
            ),
            onPanUpdate: (d) => _handleTouch(
              d.localPosition,
              Size(dialSize, dialSize),
              isFinal: false,
            ),
            onPanEnd: (_) => _handleTouch(
              _lastTouchPosition,
              Size(dialSize, dialSize),
              isFinal: true,
            ),
            onTapUp: (d) => _handleTouch(
              d.localPosition,
              Size(dialSize, dialSize),
              isFinal: true,
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                width: dialSize,
                height: dialSize,
                child: Stack(
                  children: [
                    // Layer 1 — Static dial face background & ticks & numbers (RepaintBoundary)
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size(dialSize, dialSize),
                        painter: _ClockFacePainter(
                          dialFaceColor: dialFaceColor,
                          borderColor: borderColor,
                          borderWidth: presetTokens.showsDefaultBorder
                              ? presetTokens.borderWidth
                              : 1.0,
                          tickColor: colors.textDisabled,
                          numberColor: dialTextColor,
                          disabledNumberColor: colors.textDisabled,
                          timeFormat: widget.timeFormat,
                          activeSegment: _activeSegment,
                          minuteInterval: widget.minuteInterval,
                          currentTime: time,
                          firstTime: widget.firstTime,
                          lastTime: widget.lastTime,
                          selectableTimePredicate:
                              widget.selectableTimePredicate,
                          outerRadius: outerR,
                          innerRadius: innerR,
                          textStyle: typo.bodySm,
                          innerTextStyle: typo.caption,
                          isNeobrutalism:
                              !presetTokens.timePickerCircularSelection,
                        ),
                      ),
                    ),
                    // Layer 2 — Dynamic foreground hand & selection bubble
                    CustomPaint(
                      size: Size(dialSize, dialSize),
                      painter: _ClockHandPainter(
                        angle: _currentAngle,
                        radius: _currentRadius,
                        handColor: handColor,
                        selectedTextColor: selectedTextColor,
                        selectedLabel: selectedValueLabel,
                        isUnlabelledMinute:
                            _activeSegment == .minute && (time.minute % 5 != 0),
                        isCircularSelection:
                            presetTokens.timePickerCircularSelection,
                        borderWidth: presetTokens.borderWidth,
                        borderColor: presetTokens.showsDefaultBorder
                            ? colors.textPrimary
                            : handColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Static painter for the clock dial background, tick marks, and hour/minute numbers.
class _ClockFacePainter extends CustomPainter {
  final Color dialFaceColor;
  final Color borderColor;
  final double borderWidth;
  final Color tickColor;
  final Color numberColor;
  final Color disabledNumberColor;
  final JustTimeFormat timeFormat;
  final JustTimePickerSegment activeSegment;
  final int minuteInterval;
  final TimeOfDay currentTime;
  final TimeOfDay? firstTime;
  final TimeOfDay? lastTime;
  final bool Function(TimeOfDay)? selectableTimePredicate;
  final double outerRadius;
  final double innerRadius;
  final TextStyle textStyle;
  final TextStyle innerTextStyle;
  final bool isNeobrutalism;

  _ClockFacePainter({
    required this.dialFaceColor,
    required this.borderColor,
    required this.borderWidth,
    required this.tickColor,
    required this.numberColor,
    required this.disabledNumberColor,
    required this.timeFormat,
    required this.activeSegment,
    required this.minuteInterval,
    required this.currentTime,
    required this.firstTime,
    required this.lastTime,
    required this.selectableTimePredicate,
    required this.outerRadius,
    required this.innerRadius,
    required this.textStyle,
    required this.innerTextStyle,
    required this.isNeobrutalism,
  });

  bool _isNumberAllowed(int value, bool isInnerRing) {
    TimeOfDay testTime;
    if (activeSegment == .hour) {
      if (timeFormat == .twentyFourHour) {
        testTime = currentTime.replacing(hour: value);
      } else {
        final period = currentTime.period;
        testTime = currentTime.withHour12(value, period);
      }
    } else {
      testTime = currentTime.replacing(minute: value);
    }

    if (!testTime.isWithin(firstTime, lastTime)) {
      return false;
    }
    if (selectableTimePredicate != null &&
        !selectableTimePredicate!(testTime)) {
      return false;
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dialRadius = size.width / 2;

    // 1. Dial Face Background
    final bgPaint = Paint()
      ..color = dialFaceColor
      ..style = .fill;
    canvas.drawCircle(center, dialRadius, bgPaint);

    // 2. Outer Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = .stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, dialRadius - (borderWidth / 2), borderPaint);

    // 3. Tick Marks (60 ticks around the circumference)
    final majorTickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2.0
      ..strokeCap = .round;

    final minorTickPaint = Paint()
      ..color = tickColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..strokeCap = .round;

    final tickMargin = borderWidth + 2.0;
    final tickEndRadius = dialRadius - tickMargin;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 2 * math.pi) / 60;
      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 6.0 : 3.0;
      final tickStartRadius = tickEndRadius - tickLength;

      final startX = center.dx + tickStartRadius * math.sin(angle);
      final startY = center.dy - tickStartRadius * math.cos(angle);
      final endX = center.dx + tickEndRadius * math.sin(angle);
      final endY = center.dy - tickEndRadius * math.cos(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        isMajor ? majorTickPaint : minorTickPaint,
      );
    }

    // 4. Numbers
    if (activeSegment == .hour) {
      if (timeFormat == .twentyFourHour) {
        // Outer ring: 1..12
        for (int h = 1; h <= 12; h++) {
          final sector = h % 12;
          final angle = (sector * 2 * math.pi) / 12;
          final x = center.dx + outerRadius * math.sin(angle);
          final y = center.dy - outerRadius * math.cos(angle);
          final allowed = _isNumberAllowed(h, false);

          _drawText(
            canvas: canvas,
            text: h.toString(),
            center: Offset(x, y),
            style: textStyle.copyWith(
              color: allowed ? numberColor : disabledNumberColor,
              fontWeight: .w500,
            ),
          );
        }

        // Inner ring: 00, 13..23
        for (int i = 0; i < 12; i++) {
          final hour24 = i == 0 ? 0 : i + 12;
          final angle = (i * 2 * math.pi) / 12;
          final x = center.dx + innerRadius * math.sin(angle);
          final y = center.dy - innerRadius * math.cos(angle);
          final allowed = _isNumberAllowed(hour24, true);

          _drawText(
            canvas: canvas,
            text: hour24.toString().padLeft(2, '0'),
            center: Offset(x, y),
            style: innerTextStyle.copyWith(
              color: allowed
                  ? numberColor.withValues(alpha: 0.85)
                  : disabledNumberColor,
              fontWeight: .w500,
            ),
          );
        }
      } else {
        // 12-Hour mode: 1..12
        for (int h = 1; h <= 12; h++) {
          final sector = h % 12;
          final angle = (sector * 2 * math.pi) / 12;
          final x = center.dx + outerRadius * math.sin(angle);
          final y = center.dy - outerRadius * math.cos(angle);
          final allowed = _isNumberAllowed(h, false);

          _drawText(
            canvas: canvas,
            text: h.toString(),
            center: Offset(x, y),
            style: textStyle.copyWith(
              color: allowed ? numberColor : disabledNumberColor,
              fontWeight: .w500,
            ),
          );
        }
      }
    } else {
      // Minute mode: 00, 05, 10, ... 55
      for (int m = 0; m < 60; m += 5) {
        final angle = (m * 2 * math.pi) / 60;
        final x = center.dx + outerRadius * math.sin(angle);
        final y = center.dy - outerRadius * math.cos(angle);
        final allowed = _isNumberAllowed(m, false);

        _drawText(
          canvas: canvas,
          text: m.toString().padLeft(2, '0'),
          center: Offset(x, y),
          style: textStyle.copyWith(
            color: allowed ? numberColor : disabledNumberColor,
            fontWeight: .w500,
          ),
        );
      }
    }
  }

  void _drawText({
    required Canvas canvas,
    required String text,
    required Offset center,
    required TextStyle style,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: .ltr,
    )..layout();

    final textOffset = Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _ClockFacePainter oldDelegate) {
    return dialFaceColor != oldDelegate.dialFaceColor ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        tickColor != oldDelegate.tickColor ||
        numberColor != oldDelegate.numberColor ||
        disabledNumberColor != oldDelegate.disabledNumberColor ||
        timeFormat != oldDelegate.timeFormat ||
        activeSegment != oldDelegate.activeSegment ||
        minuteInterval != oldDelegate.minuteInterval ||
        currentTime != oldDelegate.currentTime ||
        firstTime != oldDelegate.firstTime ||
        lastTime != oldDelegate.lastTime ||
        outerRadius != oldDelegate.outerRadius ||
        innerRadius != oldDelegate.innerRadius ||
        textStyle != oldDelegate.textStyle ||
        innerTextStyle != oldDelegate.innerTextStyle;
  }
}

/// Dynamic foreground painter that draws the animated clock hand, center pin,
/// and selection indicator bubble.
class _ClockHandPainter extends CustomPainter {
  final double angle;
  final double radius;
  final Color handColor;
  final Color selectedTextColor;
  final String selectedLabel;
  final bool isUnlabelledMinute;
  final bool isCircularSelection;
  final double borderWidth;
  final Color borderColor;

  _ClockHandPainter({
    required this.angle,
    required this.radius,
    required this.handColor,
    required this.selectedTextColor,
    required this.selectedLabel,
    required this.isUnlabelledMinute,
    required this.isCircularSelection,
    required this.borderWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final thumbX = center.dx + radius * math.sin(angle);
    final thumbY = center.dy - radius * math.cos(angle);
    final thumbCenter = Offset(thumbX, thumbY);

    // 1. Center Pin
    if (isCircularSelection) {
      final pinPaint = Paint()
        ..color = handColor
        ..style = .fill;
      canvas.drawCircle(center, 4.0, pinPaint);
    } else {
      // Neobrutalism square pin
      final pinRect = Rect.fromCenter(center: center, width: 8.0, height: 8.0);
      final fillPaint = Paint()
        ..color = handColor
        ..style = .fill;
      canvas.drawRect(pinRect, fillPaint);

      final borderPaint = Paint()
        ..color = borderColor
        ..style = .stroke
        ..strokeWidth = borderWidth;
      canvas.drawRect(pinRect, borderPaint);
    }

    // 2. Hand Line (from center to thumb edge)
    final handPaint = Paint()
      ..color = handColor
      ..style = .stroke
      ..strokeWidth = isCircularSelection ? 2.0 : borderWidth
      ..strokeCap = .round;
    canvas.drawLine(center, thumbCenter, handPaint);

    // 3. Thumb Selector Bubble
    const thumbRadius = 20.0;
    if (isCircularSelection) {
      final thumbPaint = Paint()
        ..color = handColor
        ..style = .fill;
      canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
    } else {
      // Neobrutalism sharp box selector
      final thumbRect = Rect.fromCenter(
        center: thumbCenter,
        width: thumbRadius * 2,
        height: thumbRadius * 2,
      );
      final fillPaint = Paint()
        ..color = handColor
        ..style = .fill;
      canvas.drawRect(thumbRect, fillPaint);

      final borderPaint = Paint()
        ..color = borderColor
        ..style = .stroke
        ..strokeWidth = borderWidth;
      canvas.drawRect(thumbRect, borderPaint);
    }

    // 4. Content inside Thumb (Label or Unlabelled Dot)
    if (isUnlabelledMinute) {
      final dotPaint = Paint()
        ..color = selectedTextColor
        ..style = .fill;
      canvas.drawCircle(thumbCenter, 3.0, dotPaint);
    } else {
      final textPainter = TextPainter(
        text: TextSpan(
          text: selectedLabel,
          style: TextStyle(
            color: selectedTextColor,
            fontSize: 14.0,
            fontWeight: .w700,
          ),
        ),
        textDirection: .ltr,
      )..layout();

      final textOffset = Offset(
        thumbCenter.dx - (textPainter.width / 2),
        thumbCenter.dy - (textPainter.height / 2),
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _ClockHandPainter oldDelegate) {
    return angle != oldDelegate.angle ||
        radius != oldDelegate.radius ||
        handColor != oldDelegate.handColor ||
        selectedTextColor != oldDelegate.selectedTextColor ||
        selectedLabel != oldDelegate.selectedLabel ||
        isUnlabelledMinute != oldDelegate.isUnlabelledMinute ||
        isCircularSelection != oldDelegate.isCircularSelection ||
        borderWidth != oldDelegate.borderWidth ||
        borderColor != oldDelegate.borderColor;
  }
}

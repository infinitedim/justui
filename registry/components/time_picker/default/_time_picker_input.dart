import 'package:flutter/material.dart' show DayPeriod, Theme, TimeOfDay;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';

import '../input/just_input.dart';
import 'just_time_picker_style.dart';
import 'just_time_picker_theme.dart';
import 'just_time_picker_variants.dart';

/// Direct numeric text input fallback mode for [JustTimePicker].
///
/// Provides a WCAG-compliant keyboard-first interface consisting of two
/// [JustInput.number] fields for hour and minute with stepper controls,
/// automatic focus traversal, input sanitization, and an AM/PM segmented toggle.
class TimePickerInput extends StatefulWidget {
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

  /// Locale strings for labels and tooltips.
  final JustTimePickerLocale locale;

  /// Per-instance style overrides.
  final JustTimePickerStyle? style;

  /// Whether to autofocus the hour input field.
  final bool autofocus;

  /// Whether haptic feedback is enabled.
  final bool? enableHaptic;

  /// Creates a [TimePickerInput] widget.
  const TimePickerInput({
    super.key,
    this.selectedTime,
    this.onChanged,
    this.firstTime,
    this.lastTime,
    this.selectableTimePredicate,
    this.timeFormat = .twelveHour,
    this.minuteInterval = 1,
    this.locale = const JustTimePickerLocale(),
    this.style,
    this.autofocus = false,
    this.enableHaptic,
  });

  @override
  State<TimePickerInput> createState() => _TimePickerInputState();
}

class _TimePickerInputState extends State<TimePickerInput> {
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late FocusNode _hourFocusNode;
  late FocusNode _minuteFocusNode;

  late TimeOfDay _currentTime;
  bool _isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.selectedTime ?? const TimeOfDay(hour: 12, minute: 0);

    _hourController = TextEditingController(text: _formatHour(_currentTime));
    _minuteController = TextEditingController(
      text: _formatMinute(_currentTime),
    );

    _hourFocusNode = FocusNode();
    _minuteFocusNode = FocusNode();

    _hourFocusNode.addListener(_onHourFocusChange);
    _minuteFocusNode.addListener(_onMinuteFocusChange);
  }

  @override
  void didUpdateWidget(covariant TimePickerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTime != oldWidget.selectedTime &&
        widget.selectedTime != null &&
        !_isInternalUpdate) {
      _currentTime = widget.selectedTime!;
      _updateControllers();
    }
  }

  @override
  void dispose() {
    _hourFocusNode.removeListener(_onHourFocusChange);
    _minuteFocusNode.removeListener(_onMinuteFocusChange);
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String _formatHour(TimeOfDay time) {
    if (widget.timeFormat == .twentyFourHour) {
      return time.hour.toString().padLeft(2, '0');
    } else {
      final h12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      return h12.toString().padLeft(2, '0');
    }
  }

  String _formatMinute(TimeOfDay time) {
    return time.minute.toString().padLeft(2, '0');
  }

  void _updateControllers() {
    final hourText = _formatHour(_currentTime);
    if (_hourController.text != hourText) {
      _hourController.text = hourText;
    }
    final minuteText = _formatMinute(_currentTime);
    if (_minuteController.text != minuteText) {
      _minuteController.text = minuteText;
    }
  }

  void _onHourFocusChange() {
    if (!_hourFocusNode.hasFocus) {
      _commitHourText();
    }
  }

  void _onMinuteFocusChange() {
    if (!_minuteFocusNode.hasFocus) {
      _commitMinuteText();
    }
  }

  void _commitHourText() {
    final parsed = int.tryParse(_hourController.text);
    int validHour;

    if (widget.timeFormat == .twentyFourHour) {
      if (parsed == null) {
        validHour = _currentTime.hour;
      } else {
        validHour = parsed.clamp(0, 23);
      }
      _applyTimeChange(_currentTime.replacing(hour: validHour));
    } else {
      if (parsed == null) {
        validHour = _currentTime.hourOfPeriod == 0
            ? 12
            : _currentTime.hourOfPeriod;
      } else {
        validHour = parsed.clamp(1, 12);
      }
      _applyTimeChange(_currentTime.withHour12(validHour, _currentTime.period));
    }
    _hourController.text = _formatHour(_currentTime);
  }

  void _commitMinuteText() {
    final parsed = int.tryParse(_minuteController.text);
    int validMinute;

    if (parsed == null) {
      validMinute = _currentTime.minute;
    } else {
      validMinute = parsed.clamp(0, 59);
      if (widget.minuteInterval > 1) {
        final snapped =
            ((validMinute / widget.minuteInterval).round() *
                widget.minuteInterval) %
            60;
        validMinute = snapped;
      }
    }

    _applyTimeChange(_currentTime.replacing(minute: validMinute));
    _minuteController.text = _formatMinute(_currentTime);
  }

  void _onHourChanged(String text) {
    var digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 2) {
      digits = digits.substring(digits.length - 2);
      _hourController.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }

    final val = int.tryParse(digits);
    if (val != null) {
      if (widget.timeFormat == .twentyFourHour) {
        if (val >= 0 && val <= 23) {
          _applyTimeChange(_currentTime.replacing(hour: val));
        }
      } else {
        if (val >= 1 && val <= 12) {
          _applyTimeChange(_currentTime.withHour12(val, _currentTime.period));
        }
      }

      // Auto-advance focus to minute after 2 digits are entered
      if (digits.length == 2) {
        _minuteFocusNode.requestFocus();
      }
    }
  }

  void _onMinuteChanged(String text) {
    var digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 2) {
      digits = digits.substring(digits.length - 2);
      _minuteController.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }

    final val = int.tryParse(digits);
    if (val != null && val >= 0 && val <= 59) {
      _applyTimeChange(_currentTime.replacing(minute: val));
    }
  }

  void _applyTimeChange(TimeOfDay newTime) {
    var validTime = newTime;

    if (!validTime.isWithin(widget.firstTime, widget.lastTime)) {
      validTime = validTime.clampTo(widget.firstTime, widget.lastTime);
    }

    if (widget.selectableTimePredicate != null &&
        !widget.selectableTimePredicate!(validTime)) {
      return;
    }

    if (validTime != _currentTime) {
      _isInternalUpdate = true;
      setState(() {
        _currentTime = validTime;
      });
      _triggerHaptic();
      widget.onChanged?.call(validTime);
      _isInternalUpdate = false;
    }
  }

  void _setPeriod(DayPeriod period) {
    if (_currentTime.period == period) return;

    final hour12 = _currentTime.hourOfPeriod == 0
        ? 12
        : _currentTime.hourOfPeriod;
    final newTime = _currentTime.withHour12(hour12, period);
    _applyTimeChange(newTime);
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

  @override
  Widget build(BuildContext context) {
    final theme = context.justTheme;
    final colors = context.justColors;
    final spacing = context.justSpacing;
    final typo = context.justTypo;

    return Center(
      child: Padding(
        padding: widget.style?.padding ?? .all(spacing.md),
        child: Row(
          mainAxisSize: .min,
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            // Hour Input Column
            SizedBox(
              width: 80.0,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                children: [
                  Semantics(
                    label: widget.locale.hourLabel,
                    child: JustInput.number(
                      controller: _hourController,
                      focusNode: _hourFocusNode,
                      autofocus: widget.autofocus,
                      textInputAction: .next,
                      onChanged: _onHourChanged,
                      onSubmitted: (_) => _minuteFocusNode.requestFocus(),
                    ),
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    widget.locale.hourLabel,
                    style: typo.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),

            // Colon separator
            Padding(
              padding: .only(
                left: spacing.xs,
                right: spacing.xs,
                bottom: spacing.lg,
              ),
              child: Text(
                ':',
                style: typo.headingLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),

            // Minute Input Column
            SizedBox(
              width: 80.0,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .center,
                children: [
                  Semantics(
                    label: widget.locale.minuteLabel,
                    child: JustInput.number(
                      controller: _minuteController,
                      focusNode: _minuteFocusNode,
                      textInputAction: .done,
                      onChanged: _onMinuteChanged,
                      onSubmitted: (_) {
                        _commitMinuteText();
                        _minuteFocusNode.unfocus();
                      },
                    ),
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    widget.locale.minuteLabel,
                    style: typo.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),

            // AM/PM Toggle Segment (12-hour format only)
            if (widget.timeFormat == .twelveHour) ...[
              SizedBox(width: spacing.sm),
              Padding(
                padding: .only(bottom: spacing.lg),
                child: _buildPeriodToggle(context, theme),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(BuildContext context, JustThemeData theme) {
    final colors = context.justColors;
    final radius = theme.radius;
    final typo = context.justTypo;
    final presetTokens = theme.presetTokens;

    final isAm = _currentTime.period == DayPeriod.am;
    final activeBg = widget.style?.periodActiveColor ?? colors.borderFocus;
    final activeFg = widget.style?.selectedTextColor ?? colors.textInverse;
    final inactiveBg = colors.muted;
    final inactiveFg = widget.style?.dialTextColor ?? colors.textSecondary;
    final borderColor =
        widget.style?.borderColor ??
        (presetTokens.showsDefaultBorder
            ? colors.borderDefault
            : colors.borderDefault);

    final resolvedRadius = presetTokens.resolveBorderRadius(radius);

    return Container(
      decoration: BoxDecoration(
        color: inactiveBg,
        borderRadius: resolvedRadius,
        border: Border.all(
          color: borderColor,
          width: presetTokens.showsDefaultBorder
              ? presetTokens.borderWidth
              : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          // AM button
          Semantics(
            button: true,
            label: widget.locale.amLabel,
            selected: isAm,
            child: GestureDetector(
              behavior: .opaque,
              onTap: () => _setPeriod(DayPeriod.am),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                padding: const .symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isAm ? activeBg : const Color(0x00000000),
                  borderRadius: resolvedRadius,
                ),
                child: Text(
                  widget.locale.amLabel,
                  style: typo.bodySm.copyWith(
                    color: isAm ? activeFg : inactiveFg,
                    fontWeight: isAm ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // PM button
          Semantics(
            button: true,
            label: widget.locale.pmLabel,
            selected: !isAm,
            child: GestureDetector(
              behavior: .opaque,
              onTap: () => _setPeriod(DayPeriod.pm),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                padding: const .symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: !isAm ? activeBg : const Color(0x00000000),
                  borderRadius: resolvedRadius,
                ),
                child: Text(
                  widget.locale.pmLabel,
                  style: typo.bodySm.copyWith(
                    color: !isAm ? activeFg : inactiveFg,
                    fontWeight: !isAm ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

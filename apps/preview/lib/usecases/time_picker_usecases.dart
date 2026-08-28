// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show DayPeriod, TimeOfDay;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ── 1. Inline Dial Time Picker ───────────────────────────────────────────────

/// Widgetbook use case for interactive inline dial time picker.
@widgetbook.UseCase(name: 'Inline Dial', type: JustTimePicker)
Widget buildJustTimePickerInlineDialUseCase(BuildContext context) {
  final timeFormat = context.knobs.object.dropdown<JustTimeFormat>(
    label: 'Time Format',
    options: JustTimeFormat.values,
    initialOption: .twelveHour,
    labelBuilder: (f) => f == .twelveHour ? '12-Hour (AM/PM)' : '24-Hour',
  );
  final minuteInterval = context.knobs.object.dropdown<int>(
    label: 'Minute Interval',
    options: const [1, 5, 10, 15, 30],
    initialOption: 5,
    labelBuilder: (i) => '$i min step',
  );
  final allowModeSwitch = context.knobs.boolean(
    label: 'Allow Mode Switch',
    initialValue: true,
  );
  final enableHaptic = context.knobs.boolean(
    label: 'Enable Haptic Feedback',
    initialValue: false,
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: _InlineDialTimePickerDemo(
          timeFormat: timeFormat,
          minuteInterval: minuteInterval,
          allowModeSwitch: allowModeSwitch,
          enableHaptic: enableHaptic,
        ),
      ),
    ),
  );
}

class _InlineDialTimePickerDemo extends StatefulWidget {
  final JustTimeFormat timeFormat;
  final int minuteInterval;
  final bool allowModeSwitch;
  final bool enableHaptic;

  const _InlineDialTimePickerDemo({
    required this.timeFormat,
    required this.minuteInterval,
    required this.allowModeSwitch,
    required this.enableHaptic,
  });

  @override
  State<_InlineDialTimePickerDemo> createState() =>
      _InlineDialTimePickerDemoState();
}

class _InlineDialTimePickerDemoState extends State<_InlineDialTimePickerDemo> {
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 10, minute: 30);

  @override
  Widget build(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .center,
      children: [
        JustTimePicker.inline(
          value: _selectedTime,
          mode: .dial,
          timeFormat: widget.timeFormat,
          minuteInterval: widget.minuteInterval,
          allowModeSwitch: widget.allowModeSwitch,
          enableHaptic: widget.enableHaptic,
          onChanged: (time) {
            setState(() {
              _selectedTime = time;
            });
          },
        ),
        const SizedBox(height: 16.0),
        Semantics(
          label: 'Selected Time Output',
          child: Text(
            _selectedTime != null
                ? 'Selected: ${_formatTime(_selectedTime!, widget.timeFormat)}'
                : 'No time selected',
            style: typo.bodyMd.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ── 2. Inline Spinner Time Picker ───────────────────────────────────────────

/// Widgetbook use case for 3-column scrollable wheel time picker.
@widgetbook.UseCase(name: 'Inline Spinner', type: JustTimePicker)
Widget buildJustTimePickerInlineSpinnerUseCase(BuildContext context) {
  final timeFormat = context.knobs.object.dropdown<JustTimeFormat>(
    label: 'Time Format',
    options: JustTimeFormat.values,
    initialOption: .twelveHour,
    labelBuilder: (f) => f == .twelveHour ? '12-Hour (AM/PM)' : '24-Hour',
  );
  final minuteInterval = context.knobs.object.dropdown<int>(
    label: 'Minute Interval',
    options: const [1, 5, 10, 15, 30],
    initialOption: 15,
    labelBuilder: (i) => '$i min step',
  );
  final allowModeSwitch = context.knobs.boolean(
    label: 'Allow Mode Switch',
    initialValue: true,
  );
  final enableHaptic = context.knobs.boolean(
    label: 'Enable Haptic Feedback',
    initialValue: false,
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: _InlineSpinnerTimePickerDemo(
          timeFormat: timeFormat,
          minuteInterval: minuteInterval,
          allowModeSwitch: allowModeSwitch,
          enableHaptic: enableHaptic,
        ),
      ),
    ),
  );
}

class _InlineSpinnerTimePickerDemo extends StatefulWidget {
  final JustTimeFormat timeFormat;
  final int minuteInterval;
  final bool allowModeSwitch;
  final bool enableHaptic;

  const _InlineSpinnerTimePickerDemo({
    required this.timeFormat,
    required this.minuteInterval,
    required this.allowModeSwitch,
    required this.enableHaptic,
  });

  @override
  State<_InlineSpinnerTimePickerDemo> createState() =>
      _InlineSpinnerTimePickerDemoState();
}

class _InlineSpinnerTimePickerDemoState
    extends State<_InlineSpinnerTimePickerDemo> {
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 14, minute: 15);

  @override
  Widget build(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .center,
      children: [
        JustTimePicker.inline(
          value: _selectedTime,
          mode: .spinner,
          timeFormat: widget.timeFormat,
          minuteInterval: widget.minuteInterval,
          allowModeSwitch: widget.allowModeSwitch,
          enableHaptic: widget.enableHaptic,
          onChanged: (time) {
            setState(() {
              _selectedTime = time;
            });
          },
        ),
        const SizedBox(height: 16.0),
        Semantics(
          label: 'Selected Time Output',
          child: Text(
            _selectedTime != null
                ? 'Selected: ${_formatTime(_selectedTime!, widget.timeFormat)}'
                : 'No time selected',
            style: typo.bodyMd.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ── 3. Inline Input Time Picker ─────────────────────────────────────────────

/// Widgetbook use case for direct numeric keyboard time input.
@widgetbook.UseCase(name: 'Inline Input', type: JustTimePicker)
Widget buildJustTimePickerInlineInputUseCase(BuildContext context) {
  final timeFormat = context.knobs.object.dropdown<JustTimeFormat>(
    label: 'Time Format',
    options: JustTimeFormat.values,
    initialOption: .twelveHour,
    labelBuilder: (f) => f == .twelveHour ? '12-Hour (AM/PM)' : '24-Hour',
  );
  final minuteInterval = context.knobs.object.dropdown<int>(
    label: 'Minute Interval',
    options: const [1, 5, 10, 15, 30],
    initialOption: 1,
    labelBuilder: (i) => '$i min step',
  );
  final allowModeSwitch = context.knobs.boolean(
    label: 'Allow Mode Switch',
    initialValue: true,
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340.0),
        child: _InlineInputTimePickerDemo(
          timeFormat: timeFormat,
          minuteInterval: minuteInterval,
          allowModeSwitch: allowModeSwitch,
        ),
      ),
    ),
  );
}

class _InlineInputTimePickerDemo extends StatefulWidget {
  final JustTimeFormat timeFormat;
  final int minuteInterval;
  final bool allowModeSwitch;

  const _InlineInputTimePickerDemo({
    required this.timeFormat,
    required this.minuteInterval,
    required this.allowModeSwitch,
  });

  @override
  State<_InlineInputTimePickerDemo> createState() =>
      _InlineInputTimePickerDemoState();
}

class _InlineInputTimePickerDemoState
    extends State<_InlineInputTimePickerDemo> {
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 9, minute: 45);

  @override
  Widget build(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .center,
      children: [
        JustTimePicker.inline(
          value: _selectedTime,
          mode: .input,
          timeFormat: widget.timeFormat,
          minuteInterval: widget.minuteInterval,
          allowModeSwitch: widget.allowModeSwitch,
          onChanged: (time) {
            setState(() {
              _selectedTime = time;
            });
          },
        ),
        const SizedBox(height: 16.0),
        Semantics(
          label: 'Selected Time Output',
          child: Text(
            _selectedTime != null
                ? 'Selected: ${_formatTime(_selectedTime!, widget.timeFormat)}'
                : 'No time selected',
            style: typo.bodyMd.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ── 4. Dropdown Popover Time Picker ─────────────────────────────────────────

/// Widgetbook use case for trigger button with anchored dropdown popover.
@widgetbook.UseCase(name: 'Dropdown popover', type: JustTimePicker)
Widget buildJustTimePickerDropdownUseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Appointment Time',
  );
  final placeholder = context.knobs.string(
    label: 'Placeholder',
    initialValue: 'Select a time...',
  );
  final mode = context.knobs.object.dropdown<JustTimePickerMode>(
    label: 'Picker Mode',
    options: JustTimePickerMode.values,
    initialOption: .dial,
    labelBuilder: (m) => m.name.toUpperCase(),
  );
  final timeFormat = context.knobs.object.dropdown<JustTimeFormat>(
    label: 'Time Format',
    options: JustTimeFormat.values,
    initialOption: .twelveHour,
    labelBuilder: (f) => f == .twelveHour ? '12-Hour (AM/PM)' : '24-Hour',
  );
  final minuteInterval = context.knobs.object.dropdown<int>(
    label: 'Minute Interval',
    options: const [1, 5, 10, 15, 30],
    initialOption: 5,
    labelBuilder: (i) => '$i min step',
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320.0),
        child: _DropdownTimePickerDemo(
          label: label,
          placeholder: placeholder,
          mode: mode,
          timeFormat: timeFormat,
          minuteInterval: minuteInterval,
        ),
      ),
    ),
  );
}

class _DropdownTimePickerDemo extends StatefulWidget {
  final String label;
  final String placeholder;
  final JustTimePickerMode mode;
  final JustTimeFormat timeFormat;
  final int minuteInterval;

  const _DropdownTimePickerDemo({
    required this.label,
    required this.placeholder,
    required this.mode,
    required this.timeFormat,
    required this.minuteInterval,
  });

  @override
  State<_DropdownTimePickerDemo> createState() =>
      _DropdownTimePickerDemoState();
}

class _DropdownTimePickerDemoState extends State<_DropdownTimePickerDemo> {
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return JustTimePicker.dropdown(
      value: _selectedTime,
      label: widget.label,
      placeholder: widget.placeholder,
      mode: widget.mode,
      timeFormat: widget.timeFormat,
      minuteInterval: widget.minuteInterval,
      onChanged: (time) {
        setState(() {
          _selectedTime = time;
        });
      },
    );
  }
}

// ── 5. Modal Dialog Time Picker ─────────────────────────────────────────────

/// Widgetbook use case for modal dialog time picker trigger.
@widgetbook.UseCase(name: 'Modal Dialog', type: JustTimePicker)
Widget buildJustTimePickerModalUseCase(BuildContext context) {
  final mode = context.knobs.object.dropdown<JustTimePickerMode>(
    label: 'Picker Mode',
    options: JustTimePickerMode.values,
    initialOption: .dial,
    labelBuilder: (m) => m.name.toUpperCase(),
  );
  final timeFormat = context.knobs.object.dropdown<JustTimeFormat>(
    label: 'Time Format',
    options: JustTimeFormat.values,
    initialOption: .twelveHour,
    labelBuilder: (f) => f == .twelveHour ? '12-Hour (AM/PM)' : '24-Hour',
  );
  final minuteInterval = context.knobs.object.dropdown<int>(
    label: 'Minute Interval',
    options: const [1, 5, 10, 15, 30],
    initialOption: 1,
    labelBuilder: (i) => '$i min step',
  );

  return Center(
    child: Padding(
      padding: const .all(16.0),
      child: _ModalTimePickerDemo(
        mode: mode,
        timeFormat: timeFormat,
        minuteInterval: minuteInterval,
      ),
    ),
  );
}

class _ModalTimePickerDemo extends StatefulWidget {
  final JustTimePickerMode mode;
  final JustTimeFormat timeFormat;
  final int minuteInterval;

  const _ModalTimePickerDemo({
    required this.mode,
    required this.timeFormat,
    required this.minuteInterval,
  });

  @override
  State<_ModalTimePickerDemo> createState() => _ModalTimePickerDemoState();
}

class _ModalTimePickerDemoState extends State<_ModalTimePickerDemo> {
  final JustDialogController _dialogController = JustDialogController();
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final colors = context.justColors;
    final typo = context.justTypo;

    return JustDialogScope(
      controller: _dialogController,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: [
          JustTimePicker.modal(
            value: _selectedTime,
            placeholder: 'Open Modal Time Picker',
            mode: widget.mode,
            timeFormat: widget.timeFormat,
            minuteInterval: widget.minuteInterval,
            onChanged: (time) {
              setState(() {
                _selectedTime = time;
              });
            },
          ),
          const SizedBox(height: 16.0),
          Semantics(
            label: 'Selected Time Output',
            child: Text(
              _selectedTime != null
                  ? 'Selected: ${_formatTime(_selectedTime!, widget.timeFormat)}'
                  : 'No time selected',
              style: typo.bodyMd.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Helpers ──────────────────────────────────────────────────────────

String _formatTime(TimeOfDay time, JustTimeFormat format) {
  if (format == .twentyFourHour) {
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  } else {
    final hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final hourStr = hourOfPeriod.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final periodStr = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hourStr:$minuteStr $periodStr';
  }
}

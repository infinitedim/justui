// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker.dart';

import '../scene.dart';

/// Part 30, time-picker: 09:41, like `KitPart` `time-picker` (hours and
/// minutes in two cells). Core's header shows the same two cells; the
/// spinner below them is how core edits the time.
Widget timePickerScene(BuildContext context, SceneContext scene) {
  return const _ClockPicker();
}

class _ClockPicker extends StatefulWidget {
  const _ClockPicker();

  @override
  State<_ClockPicker> createState() => _ClockPickerState();
}

class _ClockPickerState extends State<_ClockPicker> {
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 41);

  @override
  Widget build(BuildContext context) {
    return JustTimePicker(
      value: _time,
      onChanged: (TimeOfDay time) => setState(() => _time = time),
      mode: .spinner,
      timeFormat: .twentyFourHour,
      allowModeSwitch: false,
    );
  }
}

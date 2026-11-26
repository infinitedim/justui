// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker.dart';

import '../scene.dart';

/// Part time-picker: inline spinner starting at 09:41 AM, like `KitPart`
/// `time-picker`.
Widget timePickerScene(BuildContext context, SceneContext scene) =>
    _TimePickerDemo(scene: scene);

class const _TimePickerDemo({required final SceneContext scene})
    extends StatefulWidget {
  @override
  State<_TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<_TimePickerDemo> {
  JustTimeOfDay _selected = const JustTimeOfDay(hour: 9, minute: 41);

  JustTimePickerLocale _timeLocale(SceneContext scene) {
    return JustTimePickerLocale(
      hourLabel: scene.strings.text('hourLabel'),
      minuteLabel: scene.strings.text('minuteLabel'),
      periodLabel: scene.strings.text('periodLabel'),
      amLabel: scene.strings.text('amLabel'),
      pmLabel: scene.strings.text('pmLabel'),
      cancelLabel: scene.strings.text('cancel'),
      confirmLabel: scene.strings.text('save'),
      dialModeTooltip: scene.strings.text('dialModeTooltip'),
      inputModeTooltip: scene.strings.text('inputModeTooltip'),
      spinnerModeTooltip: scene.strings.text('spinnerModeTooltip'),
      nextValueLabel: scene.strings.text('nextValueLabel'),
      previousValueLabel: scene.strings.text('previousValueLabel'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: JustTimePicker.inline(
        mode: .spinner,
        value: _selected,
        onChanged: (JustTimeOfDay time) => setState(() => _selected = time),
        timeFormat: .twelveHour,
        semanticsLabel: widget.scene.strings.text('timePickerLabel'),
        locale: _timeLocale(widget.scene),
      ),
    );
  }
}

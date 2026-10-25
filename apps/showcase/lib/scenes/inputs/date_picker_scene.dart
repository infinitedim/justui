// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker.dart';

import '../scene.dart';
import 'date_scene_locale.dart';

/// Part 11, date-picker: October with the 17th selected, like `KitPart`
/// `date-picker`. Core shows the whole month where React shows one week.
Widget datePickerScene(BuildContext context, SceneContext scene) {
  return Semantics(
    container: true,
    label: scene.strings.text('daysLabel'),
    child: _DayPicker(scene: scene),
  );
}

class _DayPicker extends StatefulWidget {
  const _DayPicker({required this.scene});

  final SceneContext scene;

  @override
  State<_DayPicker> createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  DateTime _selected = demoDay(17);

  @override
  Widget build(BuildContext context) {
    return JustDatePicker.inline(
      value: _selected,
      onChanged: (DateTime day) => setState(() => _selected = day),
      locale: demoLocale(widget.scene),
      headerBuilder: demoHeader(widget.scene),
      style: demoStyle(context),
    );
  }
}

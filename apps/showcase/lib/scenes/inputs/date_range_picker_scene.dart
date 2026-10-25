// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_range_picker.dart';

import '../scene.dart';
import 'date_scene_locale.dart';

/// Part 12, date-range-picker: October with the 16th to the 18th selected,
/// like `KitPart` `date-range-picker`. Core shows the whole month where
/// React shows one week.
Widget dateRangePickerScene(BuildContext context, SceneContext scene) {
  return Semantics(
    container: true,
    label: scene.strings.text('daysLabel'),
    child: _RangePicker(scene: scene),
  );
}

class _RangePicker extends StatefulWidget {
  const _RangePicker({required this.scene});

  final SceneContext scene;

  @override
  State<_RangePicker> createState() => _RangePickerState();
}

class _RangePickerState extends State<_RangePicker> {
  DateTimeRange _range = DateTimeRange(start: demoDay(16), end: demoDay(18));

  @override
  Widget build(BuildContext context) {
    return JustDateRangePicker(
      value: _range,
      onChanged: (DateTimeRange range) => setState(() => _range = range),
      locale: demoLocale(widget.scene),
    );
  }
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/radio/just_radio_group.dart';

import '../scene.dart';

/// Parts 17 and 18, radio and radio-group: the frequency choice, like the shared
/// `radios` renderer of `KitPart` (weekly selected).
///
/// The outer [Semantics] is the React demo's `role="radiogroup"` with its
/// `aria-label`; core's group adds no label of its own.
Widget radioGroupScene(BuildContext context, SceneContext scene) {
  return Semantics(
    container: true,
    label: scene.strings.text('frequency'),
    child: _FrequencyGroup(
      options: <String>[
        scene.strings.text('weekly'),
        scene.strings.text('monthly'),
      ],
    ),
  );
}

class _FrequencyGroup extends StatefulWidget {
  const _FrequencyGroup({required this.options});

  final List<String> options;

  @override
  State<_FrequencyGroup> createState() => _FrequencyGroupState();
}

class _FrequencyGroupState extends State<_FrequencyGroup> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return JustRadioGroup<int>(
      value: _selected,
      onChanged: (int index) => setState(() => _selected = index),
      options: <JustRadioOption<int>>[
        for (int i = 0; i < widget.options.length; i++)
          JustRadioOption<int>(value: i, label: Text(widget.options[i])),
      ],
    );
  }
}

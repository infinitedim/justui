// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/select/just_select.dart';

import '../scene.dart';

/// Part 20, select: the frequency dropdown, like `KitPart` `select`.
///
/// Expands inline below the trigger so the open menu stays within the
/// host view without clipping, capped at `220` px (`max-w-55`) and starting
/// on `weekly`.
Widget selectScene(BuildContext context, SceneContext scene) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 220),
    child: _FrequencySelect(
      label: scene.strings.text('frequency'),
      weeklyLabel: scene.strings.text('weekly'),
      monthlyLabel: scene.strings.text('monthly'),
    ),
  );
}

class _FrequencySelect extends StatefulWidget {
  const _FrequencySelect({
    required this.label,
    required this.weeklyLabel,
    required this.monthlyLabel,
  });

  final String label;
  final String weeklyLabel;
  final String monthlyLabel;

  @override
  State<_FrequencySelect> createState() => _FrequencySelectState();
}

class _FrequencySelectState extends State<_FrequencySelect> {
  String _selected = 'weekly';

  @override
  Widget build(BuildContext context) {
    return JustSelect<String>(
      label: widget.label,
      value: _selected,
      inlineDropdown: true,
      onChanged: (String value) => setState(() => _selected = value),
      options: <JustSelectOption<String>>[
        JustSelectOption<String>(value: 'weekly', label: widget.weeklyLabel),
        JustSelectOption<String>(value: 'monthly', label: widget.monthlyLabel),
      ],
    );
  }
}

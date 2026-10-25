// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';

import '../scene.dart';

/// Part 10, checkbox: "Remember this device", checked, like `KitPart`
/// `checkbox`. It toggles like the React demo's native checkbox.
Widget checkboxScene(BuildContext context, SceneContext scene) {
  return _RememberCheckbox(label: scene.strings.text('remember'));
}

class _RememberCheckbox extends StatefulWidget {
  const _RememberCheckbox({required this.label});

  final String label;

  @override
  State<_RememberCheckbox> createState() => _RememberCheckboxState();
}

class _RememberCheckboxState extends State<_RememberCheckbox> {
  bool _checked = true;

  @override
  Widget build(BuildContext context) {
    return JustCheckbox(
      value: _checked,
      onChanged: (bool? value) => setState(() => _checked = value ?? false),
      label: Text(widget.label),
    );
  }
}

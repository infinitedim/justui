// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';

import '../scene.dart';

/// Part 27, switch: Wi-Fi, on, like `KitPart` `switch`. It toggles like the
/// React demo's native `role="switch"` checkbox.
Widget switchScene(BuildContext context, SceneContext scene) {
  return _WifiSwitch(label: scene.strings.text('wifi'));
}

class _WifiSwitch extends StatefulWidget {
  const _WifiSwitch({required this.label});

  final String label;

  @override
  State<_WifiSwitch> createState() => _WifiSwitchState();
}

class _WifiSwitchState extends State<_WifiSwitch> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return JustSwitch(
      value: _on,
      onChanged: (bool value) => setState(() => _on = value),
      label: Text(widget.label),
    );
  }
}

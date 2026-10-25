// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle.dart';

import '../scene.dart';

/// Part 09, toggle: one icon toggle for bold text, pressed by default, like
/// `KitPart` `toggle` (`KitToggle`, `defaultPressed = true`).
///
/// The Row keeps the toggle at its content width: core's toggle centers its
/// child in any bounded width it is given.
Widget toggleScene(BuildContext context, SceneContext scene) => Row(
  mainAxisSize: .min,
  children: <Widget>[_BoldToggle(label: scene.strings.text('bold'))],
);

/// The toggle keeps its own pressed state, as the React demo does.
class const _BoldToggle({required final String label}) extends StatefulWidget {
  @override
  State<_BoldToggle> createState() => _BoldToggleState();
}

class _BoldToggleState extends State<_BoldToggle> {
  bool _pressed = true;

  @override
  Widget build(BuildContext context) {
    // Core's toggle has no label of its own; this is the React aria-label
    // and aria-pressed.
    return Semantics(
      label: widget.label,
      toggled: _pressed,
      child: JustToggle(
        selected: _pressed,
        onPressed: () => setState(() => _pressed = !_pressed),
        // Core's toggle colors its child through DefaultTextStyle only, so
        // the icon reads that color to follow the pressed state.
        child: Builder(
          builder: (BuildContext context) => Icon(
            Icons.format_bold,
            size: 16,
            color: DefaultTextStyle.of(context).style.color,
          ),
        ),
      ),
    );
  }
}

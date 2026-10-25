// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/src/components/input/just_input.dart';

import '../scene.dart';

/// Part 15, input: the project name field, like `KitPart` `input`.
///
/// It starts at `just_ui` and validates as the visitor types with the same
/// rule as the React `KitInput` (`project`); an invalid value shows the
/// `badProject` message. The 240 px cap is the demo's `max-w-60`.
Widget inputScene(BuildContext context, SceneContext scene) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 240),
    child: _ProjectField(
      label: scene.strings.text('project'),
      errorMessage: scene.strings.text('badProject'),
    ),
  );
}

/// The `project` rule of the React `KitInput`.
final RegExp _projectRule = RegExp(r'^[a-z][a-z0-9_]*$');

class _ProjectField extends StatefulWidget {
  const _ProjectField({required this.label, required this.errorMessage});

  final String label;
  final String errorMessage;

  @override
  State<_ProjectField> createState() => _ProjectFieldState();
}

class _ProjectFieldState extends State<_ProjectField> {
  final TextEditingController _controller = TextEditingController(
    text: 'just_ui',
  );
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    final bool invalid = !_projectRule.hasMatch(value);
    if (invalid != _invalid) setState(() => _invalid = invalid);
  }

  @override
  Widget build(BuildContext context) {
    return JustInput(
      label: widget.label,
      controller: _controller,
      onChanged: _validate,
      errorText: _invalid ? widget.errorMessage : null,
    );
  }
}

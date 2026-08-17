// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_style.dart';

@widgetbook.UseCase(name: 'Default Checkbox', type: JustCheckbox)
Widget buildJustCheckboxDefaultUseCase(BuildContext context) {
  final isDisabled = context.knobs.boolean(
    label: 'Disabled',
    initialValue: false,
  );
  final size = context.knobs.object.dropdown<JustCheckboxSize>(
    label: 'Size',
    options: JustCheckboxSize.values,
    initialOption: JustCheckboxSize.md,
  );
  final labelText = context.knobs.string(
    label: 'Label',
    initialValue: 'Accept terms and conditions',
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: _InteractiveCheckboxDemo(
        isDisabled: isDisabled,
        size: size,
        labelText: labelText,
      ),
    ),
  );
}

class _InteractiveCheckboxDemo extends StatefulWidget {
  final bool isDisabled;
  final JustCheckboxSize size;
  final String labelText;

  const _InteractiveCheckboxDemo({
    required this.isDisabled,
    required this.size,
    required this.labelText,
  });

  @override
  State<_InteractiveCheckboxDemo> createState() =>
      _InteractiveCheckboxDemoState();
}

class _InteractiveCheckboxDemoState extends State<_InteractiveCheckboxDemo> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return JustCheckbox(
      value: _value,
      onChanged: widget.isDisabled
          ? null
          : (val) {
              setState(() {
                _value = val ?? false;
              });
            },
      isDisabled: widget.isDisabled,
      size: widget.size,
      label: Text(widget.labelText),
    );
  }
}

@widgetbook.UseCase(name: 'Indeterminate Checkbox', type: JustCheckbox)
Widget buildJustCheckboxIndeterminateUseCase(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(24.0),
      child: _InteractiveIndeterminateCheckboxDemo(),
    ),
  );
}

class _InteractiveIndeterminateCheckboxDemo extends StatefulWidget {
  const _InteractiveIndeterminateCheckboxDemo();

  @override
  State<_InteractiveIndeterminateCheckboxDemo> createState() =>
      _InteractiveIndeterminateCheckboxDemoState();
}

class _InteractiveIndeterminateCheckboxDemoState
    extends State<_InteractiveIndeterminateCheckboxDemo> {
  bool? _value;

  @override
  Widget build(BuildContext context) {
    return JustCheckbox(
      value: _value,
      onChanged: (val) {
        setState(() {
          if (_value == null) {
            _value = true;
          } else if (_value == true) {
            _value = false;
          } else {
            _value = null;
          }
        });
      },
      label: const Text('Click to cycle Indeterminate state'),
    );
  }
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/radio/just_radio.dart';
import 'package:just_ui_core/src/components/radio/just_radio_style.dart';

@widgetbook.UseCase(name: 'Default Radio', type: JustRadio)
Widget buildJustRadioDefaultUseCase(BuildContext context) {
  final isDisabled = context.knobs.boolean(
    label: 'Disabled',
    initialValue: false,
  );
  final size = context.knobs.object.dropdown<JustRadioSize>(
    label: 'Size',
    options: JustRadioSize.values,
    initialOption: JustRadioSize.md,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: _InteractiveRadioGroupDemo(isDisabled: isDisabled, size: size),
    ),
  );
}

class _InteractiveRadioGroupDemo extends StatefulWidget {
  final bool isDisabled;
  final JustRadioSize size;

  const _InteractiveRadioGroupDemo({
    required this.isDisabled,
    required this.size,
  });

  @override
  State<_InteractiveRadioGroupDemo> createState() =>
      _InteractiveRadioGroupDemoState();
}

class _InteractiveRadioGroupDemoState
    extends State<_InteractiveRadioGroupDemo> {
  String _selectedOption = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JustRadio<String>(
          value: 'Option 1',
          groupValue: _selectedOption,
          onChanged: widget.isDisabled
              ? null
              : (val) {
                  setState(() {
                    _selectedOption = val;
                  });
                },
          isDisabled: widget.isDisabled,
          size: widget.size,
          label: const Text('Option 1'),
        ),
        const SizedBox(height: 8.0),
        JustRadio<String>(
          value: 'Option 2',
          groupValue: _selectedOption,
          onChanged: widget.isDisabled
              ? null
              : (val) {
                  setState(() {
                    _selectedOption = val;
                  });
                },
          isDisabled: widget.isDisabled,
          size: widget.size,
          label: const Text('Option 2'),
        ),
        const SizedBox(height: 8.0),
        JustRadio<String>(
          value: 'Option 3',
          groupValue: _selectedOption,
          onChanged: widget.isDisabled
              ? null
              : (val) {
                  setState(() {
                    _selectedOption = val;
                  });
                },
          isDisabled: widget.isDisabled,
          size: widget.size,
          label: const Text('Option 3'),
        ),
      ],
    );
  }
}

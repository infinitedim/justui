// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/radio/just_radio.dart';
import 'package:just_ui_core/src/components/radio/just_radio_style.dart';

@widgetbook.UseCase(name: 'Default Radio', type: JustRadio)
Widget buildJustRadioDefaultUseCase(BuildContext context) {
  final selectedOption = context.knobs.object.dropdown<String>(
    label: 'Selected Option',
    options: ['Option 1', 'Option 2', 'Option 3'],
    initialOption: 'Option 1',
  );
  final isDisabled = context.knobs.boolean(
    label: 'Disabled',
    initialValue: false,
  );
  final size = context.knobs.object.dropdown<JustRadioSize>(
    label: 'Size',
    options: JustRadioSize.values,
    initialOption: JustRadioSize.md,
  );

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      JustRadio<String>(
        value: 'Option 1',
        groupValue: selectedOption,
        onChanged: isDisabled ? null : (val) {},
        isDisabled: isDisabled,
        size: size,
        label: const Text('Option 1'),
      ),
      JustRadio<String>(
        value: 'Option 2',
        groupValue: selectedOption,
        onChanged: isDisabled ? null : (val) {},
        isDisabled: isDisabled,
        size: size,
        label: const Text('Option 2'),
      ),
      JustRadio<String>(
        value: 'Option 3',
        groupValue: selectedOption,
        onChanged: isDisabled ? null : (val) {},
        isDisabled: isDisabled,
        size: size,
        label: const Text('Option 3'),
      ),
    ],
  );
}

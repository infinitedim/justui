// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_style.dart';

@widgetbook.UseCase(name: 'Default Checkbox', type: JustCheckbox)
Widget buildJustCheckboxDefaultUseCase(BuildContext context) {
  final value = context.knobs.boolean(label: 'Value', initialValue: true);
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

  return JustCheckbox(
    value: value,
    onChanged: isDisabled ? null : (val) {},
    isDisabled: isDisabled,
    size: size,
    label: Text(labelText),
  );
}

@widgetbook.UseCase(name: 'Indeterminate Checkbox', type: JustCheckbox)
Widget buildJustCheckboxIndeterminateUseCase(BuildContext context) {
  return JustCheckbox(
    value: null,
    onChanged: (val) {},
    label: const Text('Parent Selection (Indeterminate)'),
  );
}

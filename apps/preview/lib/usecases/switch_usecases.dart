// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/switch/just_switch.dart';
import 'package:just_ui_core/src/components/switch/just_switch_style.dart';

@widgetbook.UseCase(name: 'Default Switch', type: JustSwitch)
Widget buildJustSwitchDefaultUseCase(BuildContext context) {
  final value = context.knobs.boolean(label: 'Value', initialValue: true);
  final isDisabled = context.knobs.boolean(
    label: 'Is Disabled',
    initialValue: false,
  );
  final size = context.knobs.object.dropdown<JustSwitchSize>(
    label: 'Size',
    options: JustSwitchSize.values,
    initialOption: JustSwitchSize.md,
  );
  final hasLabel = context.knobs.boolean(
    label: 'Has Label',
    initialValue: true,
  );

  return JustSwitch(
    value: value,
    onChanged: isDisabled ? null : (val) {},
    isDisabled: isDisabled,
    size: size,
    label: hasLabel ? const Text('Enable Notifications') : null,
  );
}

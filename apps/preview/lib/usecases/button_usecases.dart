// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:just_ui_core/src/components/button/just_button_variants.dart';

@widgetbook.UseCase(name: 'Default Button', type: JustButton)
Widget buildJustButtonDefaultUseCase(BuildContext context) {
  return JustButton(
    label: context.knobs.string(label: 'Label', initialValue: 'Click Me'),
    onPressed: context.knobs.boolean(label: 'Enabled', initialValue: true)
        ? () {}
        : null,
    variant: context.knobs.object.dropdown<JustButtonVariant>(
      label: 'Variant',
      options: JustButtonVariant.values,
      initialOption: JustButtonVariant.primary,
    ),
    size: context.knobs.object.dropdown<JustButtonSize>(
      label: 'Size',
      options: JustButtonSize.values,
      initialOption: JustButtonSize.md,
    ),
    isLoading: context.knobs.boolean(label: 'Is Loading', initialValue: false),
    isDisabled: context.knobs.boolean(
      label: 'Is Disabled',
      initialValue: false,
    ),
    isFullWidth: context.knobs.boolean(
      label: 'Is Full Width',
      initialValue: false,
    ),
  );
}

@widgetbook.UseCase(name: 'Button Group', type: JustButton)
Widget buildJustButtonGroupUseCase(BuildContext context) {
  final attached = context.knobs.boolean(label: 'Attached', initialValue: true);
  final direction = context.knobs.object.dropdown<Axis>(
    label: 'Direction',
    options: [Axis.horizontal, Axis.vertical],
    initialOption: Axis.horizontal,
  );

  return JustButtonGroup(
    attached: attached,
    direction: direction,
    children: [
      JustButton.primary(label: 'Left', onPressed: () {}),
      JustButton.secondary(label: 'Middle', onPressed: () {}),
      JustButton.ghost(label: 'Right', onPressed: () {}),
    ],
  );
}

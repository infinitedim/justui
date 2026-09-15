// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:just_ui_core/src/components/button/just_button_variants.dart';

@widgetbook.UseCase(name: 'Default Button', type: JustButton)
Widget buildJustButtonDefaultUseCase(BuildContext context) {
  final bool enabled = context.knobs.boolean(
    label: 'Enabled',
    initialValue: true,
  );
  final JustButtonSize size = context.knobs.object.dropdown<JustButtonSize>(
    label: 'Size',
    options: JustButtonSize.values,
    initialOption: JustButtonSize.md,
  );
  final bool isLoading = context.knobs.boolean(
    label: 'Is Loading',
    initialValue: false,
  );
  final bool isDisabled = context.knobs.boolean(
    label: 'Is Disabled',
    initialValue: false,
  );
  final bool isFullWidth = context.knobs.boolean(
    label: 'Is Full Width',
    initialValue: false,
  );

  final void Function()? onPressed = enabled ? () {} : null;
  const List<JustButtonVariant> variants = JustButtonVariant.values;

  String getVariantLabel(JustButtonVariant variant) {
    final String name = variant.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  return Center(
    child: Padding(
      padding: const .all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600.0),
        child: isFullWidth
            ? Column(
                mainAxisSize: .min,
                children: variants.map((JustButtonVariant variant) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: JustButton(
                      label: getVariantLabel(variant),
                      onPressed: onPressed,
                      variant: variant,
                      size: size,
                      isLoading: isLoading,
                      isDisabled: isDisabled,
                      isFullWidth: true,
                    ),
                  );
                }).toList(),
              )
            : Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: variants.map((JustButtonVariant variant) {
                  return JustButton(
                    label: getVariantLabel(variant),
                    onPressed: onPressed,
                    variant: variant,
                    size: size,
                    isLoading: isLoading,
                    isDisabled: isDisabled,
                    isFullWidth: false,
                  );
                }).toList(),
              ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Button Group', type: JustButton)
Widget buildJustButtonGroupUseCase(BuildContext context) {
  final bool attached = context.knobs.boolean(
    label: 'Attached',
    initialValue: true,
  );
  final Axis direction = context.knobs.object.dropdown<Axis>(
    label: 'Direction',
    options: <Axis>[Axis.horizontal, Axis.vertical],
    initialOption: Axis.horizontal,
  );

  return Center(
    child: Padding(
      padding: const .all(24.0),
      child: JustButtonGroup(
        attached: attached,
        direction: direction,
        children: <JustButton>[
          JustButton.primary(label: 'Left', onPressed: () {}),
          JustButton.secondary(label: 'Middle', onPressed: () {}),
          JustButton.ghost(label: 'Right', onPressed: () {}),
        ],
      ),
    ),
  );
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/toggle/just_toggle.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_variants.dart';

@widgetbook.UseCase(name: 'Default Toggle', type: JustToggle)
Widget buildJustToggleDefaultUseCase(BuildContext context) {
  final selected = context.knobs.boolean(label: 'Selected', initialValue: true);
  final size = context.knobs.object.dropdown<JustToggleSize>(
    label: 'Size',
    options: JustToggleSize.values,
    initialOption: JustToggleSize.md,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: JustToggle(
        selected: selected,
        onPressed: () {},
        size: size,
        child: const Text('Bold'),
      ),
    ),
  );
}

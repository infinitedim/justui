// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/input/just_input.dart';
import 'package:just_ui_core/src/components/input/just_input_variants.dart';

@widgetbook.UseCase(name: 'Default Input', type: JustInput)
Widget buildJustInputDefaultUseCase(BuildContext context) {
  return JustInput(
    label: context.knobs.string(label: 'Label', initialValue: 'Email Address'),
    hint: context.knobs.string(label: 'Hint', initialValue: 'user@example.com'),
    helper: context.knobs.string(
      label: 'Helper Text',
      initialValue: 'We will never share your email.',
    ),
    errorText: context.knobs.string(label: 'Error Text', initialValue: ''),
    enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    readOnly: context.knobs.boolean(label: 'Read Only', initialValue: false),
    size: context.knobs.object.dropdown<JustInputSize>(
      label: 'Size',
      options: JustInputSize.values,
      initialOption: JustInputSize.md,
    ),
    showClearButton: context.knobs.boolean(
      label: 'Show Clear Button',
      initialValue: true,
    ),
  );
}

@widgetbook.UseCase(name: 'Password Input', type: JustInput)
Widget buildJustInputPasswordUseCase(BuildContext context) {
  return JustInput.password(
    label: context.knobs.string(label: 'Label', initialValue: 'Password'),
    hint: context.knobs.string(label: 'Hint', initialValue: 'Enter password'),
    enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    size: context.knobs.object.dropdown<JustInputSize>(
      label: 'Size',
      options: JustInputSize.values,
      initialOption: JustInputSize.md,
    ),
  );
}

@widgetbook.UseCase(name: 'Search Input', type: JustInput)
Widget buildJustInputSearchUseCase(BuildContext context) {
  return JustInput.search(
    hint: context.knobs.string(
      label: 'Hint',
      initialValue: 'Search components...',
    ),
    enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
    size: context.knobs.object.dropdown<JustInputSize>(
      label: 'Size',
      options: JustInputSize.values,
      initialOption: JustInputSize.md,
    ),
  );
}

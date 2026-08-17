// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/progress/just_progress.dart';
import 'package:just_ui_core/src/components/progress/just_progress_variants.dart';
import 'package:just_ui_core/src/components/shared/_shared_progress_spinner.dart';

@widgetbook.UseCase(name: 'Linear Progress', type: JustProgress)
Widget buildJustProgressLinearUseCase(BuildContext context) {
  final value = context.knobs.double.slider(
    label: 'Progress Value',
    initialValue: 0.6,
    min: 0.0,
    max: 1.0,
  );
  final showLabel = context.knobs.boolean(
    label: 'Show Label',
    initialValue: true,
  );
  final size = context.knobs.object.dropdown<JustProgressSize>(
    label: 'Size',
    options: JustProgressSize.values,
    initialOption: JustProgressSize.md,
  );

  return SizedBox(
    width: 300.0,
    child: JustProgress(value: value, showLabel: showLabel, size: size),
  );
}

@widgetbook.UseCase(name: 'Circular Progress', type: JustProgress)
Widget buildJustProgressCircularUseCase(BuildContext context) {
  final value = context.knobs.double.slider(
    label: 'Progress Value',
    initialValue: 0.75,
    min: 0.0,
    max: 1.0,
  );
  final size = context.knobs.object.dropdown<JustProgressSize>(
    label: 'Size',
    options: JustProgressSize.values,
    initialOption: JustProgressSize.md,
  );

  return JustProgress.circular(value: value, showLabel: true, size: size);
}

@widgetbook.UseCase(
  name: 'Variable Arc Sweep Spinner',
  type: JustProgressSpinner,
)
Widget buildJustProgressSpinnerUseCase(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'Size',
    initialValue: 24.0,
    min: 12.0,
    max: 64.0,
  );
  final strokeWidth = context.knobs.double.slider(
    label: 'Stroke Width',
    initialValue: 2.5,
    min: 1.0,
    max: 6.0,
  );

  final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;

  return Center(
    child: JustProgressSpinner(
      size: size,
      color: colors.borderFocus,
      strokeWidth: strokeWidth,
    ),
  );
}

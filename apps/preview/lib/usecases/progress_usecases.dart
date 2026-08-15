// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/progress/just_progress.dart';
import 'package:just_ui_core/src/components/progress/just_progress_variants.dart';

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

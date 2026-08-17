// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/separator/just_separator.dart';

@widgetbook.UseCase(name: 'Horizontal Separator', type: JustSeparator)
Widget buildJustSeparatorHorizontalUseCase(BuildContext context) {
  final label = context.knobs.string(label: 'Label', initialValue: 'OR');

  return SizedBox(
    width: 300.0,
    child: JustSeparator(label: label.isEmpty ? null : label),
  );
}

@widgetbook.UseCase(name: 'Vertical Separator', type: JustSeparator)
Widget buildJustSeparatorVerticalUseCase(BuildContext context) {
  return const SizedBox(
    height: 100.0,
    child: Row(
      mainAxisSize: .min,
      children: [
        Text('Left Item'),
        SizedBox(width: 12.0),
        JustSeparator(direction: .vertical),
        SizedBox(width: 12.0),
        Text('Right Item'),
      ],
    ),
  );
}

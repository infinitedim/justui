// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/badge/just_badge.dart';
import 'package:just_ui_core/src/components/badge/just_badge_variants.dart';

@widgetbook.UseCase(name: 'Default Badge', type: JustBadge)
Widget buildJustBadgeDefaultUseCase(BuildContext context) {
  final label = context.knobs.string(label: 'Label', initialValue: 'Badge');
  final color = context.knobs.object.dropdown<JustBadgeColor>(
    label: 'Color',
    options: JustBadgeColor.values,
    initialOption: JustBadgeColor.primary,
  );
  final variant = context.knobs.object.dropdown<JustBadgeVariant>(
    label: 'Variant',
    options: JustBadgeVariant.values,
    initialOption: JustBadgeVariant.solid,
  );
  final size = context.knobs.object.dropdown<JustBadgeSize>(
    label: 'Size',
    options: JustBadgeSize.values,
    initialOption: JustBadgeSize.md,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: JustBadge(
        label: label,
        color: color,
        variant: variant,
        size: size,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Dot Badge', type: JustBadge)
Widget buildJustBadgeDotUseCase(BuildContext context) {
  final pulse = context.knobs.boolean(label: 'Pulse', initialValue: true);
  final color = context.knobs.object.dropdown<JustBadgeColor>(
    label: 'Color',
    options: JustBadgeColor.values,
    initialOption: JustBadgeColor.error,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: JustBadge.dot(pulse: pulse, color: color),
    ),
  );
}

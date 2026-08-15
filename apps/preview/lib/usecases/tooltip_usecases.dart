// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/tooltip/just_tooltip.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip_variants.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';

@widgetbook.UseCase(name: 'Default Tooltip', type: JustTooltip)
Widget buildJustTooltipDefaultUseCase(BuildContext context) {
  final message = context.knobs.string(
    label: 'Message',
    initialValue: 'Save changes to cloud',
  );
  final position = context.knobs.object.dropdown<TooltipPosition>(
    label: 'Position',
    options: TooltipPosition.values,
    initialOption: TooltipPosition.top,
  );

  return Center(
    child: JustTooltip(
      message: message,
      position: position,
      child: JustButton.primary(
        label: 'Hover or Long Press Me',
        onPressed: () {},
      ),
    ),
  );
}

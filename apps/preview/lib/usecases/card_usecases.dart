// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/card/just_card.dart';
import 'package:just_ui_core/src/components/card/just_card_style.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';

@widgetbook.UseCase(name: 'Default Card', type: JustCard)
Widget buildJustCardDefaultUseCase(BuildContext context) {
  final variant = context.knobs.object.dropdown<JustCardVariant>(
    label: 'Variant',
    options: JustCardVariant.values,
    initialOption: JustCardVariant.elevated,
  );
  final isInteractive = context.knobs.boolean(
    label: 'Interactive (onTap)',
    initialValue: true,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: JustCard(
        variant: variant,
        width: 340.0,
        onTap: isInteractive ? () {} : null,
        header: const JustCardHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JustCardTitle(child: Text('Card Title')),
              JustCardDescription(
                child: Text('This is a description of the card.'),
              ),
            ],
          ),
        ),
        footer: JustCardFooter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              JustButton.ghost(label: 'Cancel', onPressed: () {}),
              const SizedBox(width: 8.0),
              JustButton.primary(label: 'Confirm', onPressed: () {}),
            ],
          ),
        ),
        child: const Text(
          'Card body content goes here. It supports any custom child widget layout.',
        ),
      ),
    ),
  );
}

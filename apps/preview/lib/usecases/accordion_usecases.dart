// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/accordion/just_accordion.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion_variants.dart';

@widgetbook.UseCase(name: 'Default Accordion', type: JustAccordion)
Widget buildJustAccordionDefaultUseCase(BuildContext context) {
  final allowMultiple = context.knobs.boolean(
    label: 'Allow Multiple',
    initialValue: false,
  );
  final variant = context.knobs.object.dropdown<JustAccordionVariant>(
    label: 'Variant',
    options: JustAccordionVariant.values,
    initialOption: JustAccordionVariant.default_,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460.0),
        child: JustAccordion(
          allowMultiple: allowMultiple,
          variant: variant,
          items: const [
            JustAccordionItem(
              title: 'Is JustAccordion accessible?',
              content: Text(
                'Yes, it adheres to WCAG AA guidelines with keyboard navigation and semantics.',
              ),
            ),
            JustAccordionItem(
              title: 'How do theme presets work?',
              content: Text(
                'Theme presets like Neobrutalism update borders, shadows, and interaction dynamics seamlessly.',
              ),
            ),
            JustAccordionItem(
              title: 'Can it be customized?',
              content: Text(
                'You can override styles per instance or globally via JustAccordionTheme.',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/scroll/just_scroll_area.dart';

@widgetbook.UseCase(name: 'Default Scroll Area', type: JustScrollArea)
Widget buildJustScrollAreaDefaultUseCase(BuildContext context) {
  final fadeEdges = context.knobs.boolean(
    label: 'Fade Edges',
    initialValue: true,
  );
  final showScrollbar = context.knobs.boolean(
    label: 'Show Scrollbar',
    initialValue: true,
  );
  final scrollToTopButton = context.knobs.boolean(
    label: 'Scroll to Top Button',
    initialValue: true,
  );

  return JustScrollArea(
    maxHeight: 250.0,
    fadeEdges: fadeEdges,
    showScrollbar: showScrollbar,
    scrollToTopButton: scrollToTopButton,
    child: Column(
      children: List.generate(
        20,
        (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Scrollable item row #${index + 1}'),
        ),
      ),
    ),
  );
}

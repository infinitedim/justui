import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsData, SemanticsNode;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion.dart';
import 'package:just_ui_core/src/components/carousel/just_carousel.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker_variants.dart';

/// Screen reader labels that used to be English-only can be translated;
/// the defaults keep the old English text.
void main() {
  Widget app(Widget child) => MaterialApp(
    home: JustThemeProvider(
      lightTheme: JustThemeData.light,
      darkTheme: JustThemeData.dark,
      child: Scaffold(body: SizedBox(width: 360, child: child)),
    ),
  );

  Widget carousel({String? label}) => app(
    SizedBox(
      height: 200,
      child: JustCarousel(
        indicator: .dots,
        indicatorSemanticsLabel: label ?? 'Slide {index}',
        children: const <Widget>[Text('A'), Text('B')],
      ),
    ),
  );

  testWidgets('carousel dots read the label template', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(carousel(label: 'Ke slide {index}'));
    expect(find.bySemanticsLabel('Ke slide 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Ke slide 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Slide 1'), findsNothing);
  });

  testWidgets('carousel dots default to Slide N', (WidgetTester tester) async {
    await tester.pumpWidget(carousel());
    expect(find.bySemanticsLabel('Slide 1'), findsOneWidget);
  });

  testWidgets('date cells read the day label template', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        JustDatePicker.inline(
          value: DateTime(2025, 10, 17),
          locale: const JustDatePickerLocale(
            monthNames: <String>[
              'Januari',
              'Februari',
              'Maret',
              'April',
              'Mei',
              'Juni',
              'Juli',
              'Agustus',
              'September',
              'Oktober',
              'November',
              'Desember',
            ],
            dayLabel: 'Tanggal {day} {month} {year}',
          ),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(RegExp('^Tanggal 20 Oktober 2025')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('^Day ')), findsNothing);
  });

  testWidgets('date cells default to Day N, Month Year', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(JustDatePicker.inline(value: DateTime(2025, 10, 17))),
    );
    expect(
      find.bySemanticsLabel(RegExp('^Day 20, October 2025')),
      findsOneWidget,
    );
  });

  testWidgets('accordion states its expansion as a flag, not English text', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      app(
        const JustAccordion(
          items: <JustAccordionItem>[
            JustAccordionItem(title: 'Apa itu runner?', content: Text('Isi')),
          ],
        ),
      ),
    );
    final List<SemanticsData> nodes = <SemanticsData>[];
    bool visit(SemanticsNode node) {
      nodes.add(node.getSemanticsData());
      node.visitChildren(visit);
      return true;
    }

    visit(tester.getSemantics(find.byType(JustAccordion)));
    final String words = nodes
        .map((SemanticsData d) => '${d.label} ${d.value}')
        .join(' ');
    expect(words, isNot(contains('Accordion Panel')));
    expect(words, isNot(contains('Collapsed')));
    expect(
      nodes.where(
        (SemanticsData d) => d.flagsCollection.isExpanded == Tristate.isFalse,
      ),
      isNotEmpty,
    );
    handle.dispose();
  });
}

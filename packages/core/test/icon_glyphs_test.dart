import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion.dart';
import 'package:just_ui_core/src/components/select/just_select.dart';
import 'package:just_ui_core/src/components/table/just_table.dart';

/// Core draws Material icons through the `Icons` constants. A raw codepoint
/// from the web icon font points at a different glyph in Flutter's font
/// (0xe5c5 is `smart_toy` there, not a chevron).
void main() {
  Widget app(Widget child) => MaterialApp(
    home: JustThemeProvider(
      lightTheme: JustThemeData.light,
      darkTheme: JustThemeData.dark,
      child: Scaffold(body: SizedBox(width: 320, child: child)),
    ),
  );

  Iterable<IconData?> icons(WidgetTester tester) =>
      tester.widgetList<Icon>(find.byType(Icon)).map((Icon i) => i.icon);

  test('no component builds an icon from a raw codepoint', () {
    final RegExp rawIcon = RegExp(r'IconData\(0x', caseSensitive: false);
    final List<String> raw = Directory('lib/src/components')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .where((File f) => rawIcon.hasMatch(f.readAsStringSync()))
        .map((File f) => f.path)
        .toList();
    expect(raw, isEmpty);
  });

  testWidgets('accordion chevron is expand_more', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const JustAccordion(
          items: <JustAccordionItem>[
            JustAccordionItem(title: 'Runner', content: Text('Body')),
          ],
        ),
      ),
    );
    expect(icons(tester), contains(Icons.expand_more));
  });

  testWidgets('select chevron is expand_more', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        JustSelect<String>(
          value: 'a',
          options: const <JustSelectOption<String>>[
            JustSelectOption<String>(value: 'a', label: 'Weekly'),
          ],
          onChanged: (_) {},
        ),
      ),
    );
    expect(icons(tester), contains(Icons.expand_more));
  });

  testWidgets('table sort icons', (WidgetTester tester) async {
    Widget table({required int? sorted, required bool ascending}) => app(
      JustTable<int>(
        columns: <JustTableColumn<int>>[
          JustTableColumn<int>(
            header: 'Part',
            cell: (int row) => Text('$row'),
            sortable: true,
          ),
        ],
        rows: const <int>[1, 2],
        sortColumnIndex: sorted,
        sortAscending: ascending,
        onSort: (_) {},
      ),
    );
    await tester.pumpWidget(table(sorted: null, ascending: true));
    expect(icons(tester), contains(Icons.unfold_more));
    await tester.pumpWidget(table(sorted: 0, ascending: true));
    expect(icons(tester), contains(Icons.arrow_drop_up));
    await tester.pumpWidget(table(sorted: 0, ascending: false));
    expect(icons(tester), contains(Icons.arrow_drop_down));
  });
}

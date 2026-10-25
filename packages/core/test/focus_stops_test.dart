import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/select/just_select.dart';

/// A control is one Tab stop: a second, invisible stop on the same control
/// makes keyboard users press Tab twice with nothing shown in between.
void main() {
  Widget app(Widget child) => MaterialApp(
    home: JustThemeProvider(
      lightTheme: JustThemeData.light,
      darkTheme: JustThemeData.dark,
      child: Scaffold(body: SizedBox(width: 320, child: child)),
    ),
  );

  /// Non-scope nodes Tab visits before it wraps.
  Future<List<FocusNode>> stops(WidgetTester tester) async {
    final List<FocusNode> seen = <FocusNode>[];
    for (int i = 0; i < 10; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final FocusNode node = FocusManager.instance.primaryFocus!;
      if (seen.contains(node)) break;
      if (node is! FocusScopeNode) seen.add(node);
    }
    return seen;
  }

  testWidgets('select trigger is one Tab stop and opens with Enter', (
    WidgetTester tester,
  ) async {
    int value = 0;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              JustSelect<int>(
                value: value,
                onChanged: (int v) => setState(() => value = v),
                options: const <JustSelectOption<int>>[
                  JustSelectOption<int>(value: 0, label: 'Weekly'),
                  JustSelectOption<int>(value: 1, label: 'Monthly'),
                ],
              ),
        ),
      ),
    );
    expect(await stops(tester), hasLength(1));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Monthly'), findsOneWidget);
  });
}

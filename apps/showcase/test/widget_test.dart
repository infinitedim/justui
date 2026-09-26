import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:showcase/main.dart';

void main() {
  testWidgets('CLI sandbox gallery renders installed components', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('JustUI CLI Sandbox'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Soft'), findsOneWidget);
    expect(find.text('Project name'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Install progress'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

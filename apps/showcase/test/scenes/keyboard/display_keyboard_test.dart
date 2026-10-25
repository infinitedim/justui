// ignore_for_file: implementation_imports
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/src/components/carousel/just_carousel.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC12 for the Display scenes: accordion and carousel take focus; the
/// rest do not, so Tab passes their views.
void main() {
  testWidgets('accordion: one stop, Enter opens the answer', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'accordion');
    const String answer = 'One preset, with every part on it.';
    final List<FocusNode> stops = await tabStops(tester);
    expect(stops, hasLength(1));
    expect(find.text(answer).hitTestable(), findsNothing);
    await activate(tester, stops.single);
    expect(find.text(answer).hitTestable(), findsOneWidget);
  });

  testWidgets('carousel: Tab reaches it and the arrow keys change slides', (
    WidgetTester tester,
  ) async {
    await pumpDefault(tester, 'carousel');
    expect(find.text('Slide 1 of 3'), findsOneWidget);
    final List<FocusNode> stops = await tabStops(tester);
    expect(
      stops.first.context?.findAncestorWidgetOfExactType<JustCarousel>(),
      isNotNull,
    );
    stops.first.requestFocus();
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Slide 2 of 3'), findsOneWidget);
    expect(find.text('Slide 1 of 3'), findsNothing);
  });

  for (final String scene in <String>[
    'avatar',
    'avatar-group',
    'badge',
    'card',
    'progress',
    'skeleton',
    'table',
  ]) {
    testWidgets('$scene has no tab stops', (WidgetTester tester) async {
      await pumpDefault(tester, scene);
      await expectNoStops(tester);
    });
  }
}

import 'package:flutter_test/flutter_test.dart';

import '../support/golden_harness.dart';
import '../support/scene_sizes.dart';

/// The ID copy the docs send (`kitTranslations.id`), for the keys these
/// scenes read.
const Map<String, Object> _id = <String, Object>{
  'month': 'Oktober',
  'weekdays': <String>['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
  'dayLabel': '{day} {month} {year}',
  'daysLabel': 'Hari di bulan Oktober',
  'slide': 'Slide {index} dari {total}',
  'slideAria': 'Ke slide {index}',
  'slidesLabel': 'Slide',
};

/// Calendars and carousel dots speak the page's language: no core English
/// reaches the screen or a screen reader on an ID page.
void main() {
  Future<SemanticsHandle> pumpId(WidgetTester tester, String scene) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpScene(
      tester,
      scene: scene,
      preset: .default_,
      mode: .light,
      size: sceneSizes[scene]!,
      strings: _id,
    );
    return handle;
  }

  for (final String scene in <String>['date-picker', 'date-range-picker']) {
    testWidgets('$scene in ID', (WidgetTester tester) async {
      final SemanticsHandle handle = await pumpId(tester, scene);
      expect(find.text('Oktober'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);
      expect(find.text('Sun'), findsNothing);
      expect(find.bySemanticsLabel(RegExp('^20 Oktober 2025')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Day ')), findsNothing);
      handle.dispose();
    });
  }

  testWidgets('carousel in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'carousel');
    expect(find.text('Slide 1 dari 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Ke slide 2'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Slide \d$')), findsNothing);
    handle.dispose();
  });
}

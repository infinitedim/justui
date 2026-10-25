import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC12 for the Display scenes: none takes focus, so Tab passes the view.
void main() {
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

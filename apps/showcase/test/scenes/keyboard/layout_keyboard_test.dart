import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC12 for the Layout scenes: the separator takes no focus, so Tab passes
/// its view.
void main() {
  testWidgets('separator has no tab stops', (WidgetTester tester) async {
    await pumpDefault(tester, 'separator');
    await expectNoStops(tester);
  });
}

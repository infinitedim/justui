import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_harness.dart';
import '../../support/keyboard.dart';

/// AC12 for the Navigation scenes: no stops, so Tab passes the view.
void main() {
  testWidgets('breadcrumb: plain text, no stop', (WidgetTester tester) async {
    await pumpDefault(tester, 'breadcrumb');
    await expectNoStops(tester);
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/widgets/showcase_marquee.dart';
import 'package:showcase/widgets/switch/just_switch.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Interactive controls states are synchronized between duplicate strips', (
    WidgetTester tester,
  ) async {
    // Set a very wide viewport to avoid off-screen overflow during tap testing
    tester.view.physicalSize = const Size(5000.0, 600.0);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      JustThemeProvider(
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: ShowcaseMarquee(),
        ),
      ),
    );

    // Find all JustSwitch widgets in the tree. There should be exactly two.
    final switchFinder = find.byType(JustSwitch);
    expect(switchFinder, findsNWidgets(2));

    // Get initial states. Since both switch state values start at true:
    final switch1 = tester.widget<JustSwitch>(switchFinder.at(0));
    final switch2 = tester.widget<JustSwitch>(switchFinder.at(1));
    expect(switch1.value, isTrue);
    expect(switch2.value, isTrue);

    // Tap the first switch to toggle it
    await tester.tap(switchFinder.at(0));
    // Pump a single frame to process the event
    await tester.pump();

    // Verify the state of both switches after the tap
    final switch1After = tester.widget<JustSwitch>(switchFinder.at(0));
    final switch2After = tester.widget<JustSwitch>(switchFinder.at(1));

    // The first switch should have toggled to false
    expect(switch1After.value, isFalse);

    // If state is synchronized, switch2 also changes to false, preventing a visual jump when looping!
    expect(switch2After.value, isFalse);
    
    // Reset view size
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

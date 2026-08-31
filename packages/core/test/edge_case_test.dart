import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area.dart';
import 'package:just_ui_core/src/components/select/just_select.dart';
import 'package:just_ui_core/src/components/slider/just_slider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hard-to-Reproduce Edge Case Tests', () {
    testWidgets(
      'Concurrent Theme Seed Mutation & High Contrast Eviction mid-frame during Overlay Disposal and In-Flight Ticker',
      (WidgetTester tester) async {
        JustThemeData currentTheme = JustThemeData.light;
        bool isMounted = true;
        String selectedVal = 'Item A';
        double sliderVal = 40.0;
        final scrollController = ScrollController();

        final options = [
          const JustSelectOption(value: 'Item A', label: 'Item A'),
          const JustSelectOption(value: 'Item B', label: 'Item B'),
        ];

        Widget buildComplexTree() {
          return MaterialApp(
            home: JustThemeProvider(
              lightTheme: currentTheme,
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    if (!isMounted) return const SizedBox.shrink();
                    return JustScrollArea(
                      controller: scrollController,
                      smoothScroll: true,
                      child: Column(
                        children: [
                          JustSelect<String>(
                            value: selectedVal,
                            options: options,
                            onChanged: (v) {
                              setState(() => selectedVal = v);
                            },
                          ),
                          JustSlider(
                            value: sliderVal,
                            min: 0.0,
                            max: 100.0,
                            onChanged: (v) => setState(() => sliderVal = v),
                          ),
                          ....generate(
                            40,
                            (index) => SizedBox(
                              height: 50.0,
                              child: Text('Row #$index'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }

        // 1. Mount complex widget tree
        await tester.pumpWidget(buildComplexTree());

        // 2. Open JustSelect overlay dropdown
        await tester.tap(find.byType(JustSelect<String>));
        await tester.pumpAndSettle();
        expect(find.text('Item B'), findsOneWidget);

        // 3. Dispatch smooth scroll pointer signal to start in-flight ticker
        tester.binding.handlePointerEvent(
          const PointerScrollEvent(
            position: Offset(200, 200),
            scrollDelta: Offset(0, 100),
          ),
        );

        // Advance 1ms to put ticker in active in-flight state
        await tester.pump(const Duration(milliseconds: 1));

        // 4. Mid-frame: Mutate theme seed + apply high contrast + unmount widget tree
        currentTheme = JustThemeData.fromSeed(
          const Color(0xFFFF0055),
          isDark: false,
        ).applyHighContrastOverrides();

        isMounted = false;

        // Re-pump widget tree with unmounted state and mutated theme mid-flight
        await tester.pumpWidget(buildComplexTree());
        await tester.pumpAndSettle();

        // 5. Verify zero errors, clean teardown, no orphaned overlay entries
        expect(find.text('Item B'), findsNothing);
        expect(find.byType(JustScrollArea), findsNothing);
      },
    );
  });
}

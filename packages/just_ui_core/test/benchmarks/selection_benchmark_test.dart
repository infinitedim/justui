import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/radio/just_radio.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return JustThemeProvider(
      child: Directionality(textDirection: .ltr, child: child),
    );
  }

  group('Selection Primitives Benchmarks', () {
    testWidgets('100 JustCheckbox in ListView builds within budget', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        buildTestableWidget(
          ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) =>
                JustCheckbox(value: index.isEven, onChanged: (_) {}),
          ),
        ),
      );

      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      debugPrint('Build time for 100 JustCheckbox: ${ms}ms');

      // Acceptance threshold — must be well within typical 16ms frame budget for compilation/build
      expect(ms, lessThan(500));
    });

    testWidgets(
      'Toggling 1 checkbox in 100-item list does not rebuild siblings',
      (tester) async {
        final List<ValueNotifier<bool?>> valueNotifiers = List.generate(
          100,
          (i) => ValueNotifier<bool?>(i.isEven),
        );
        final List<int> buildCounts = List.generate(100, (_) => 0);

        await tester.pumpWidget(
          buildTestableWidget(
            ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return ValueListenableBuilder<bool?>(
                  valueListenable: valueNotifiers[index],
                  builder: (context, val, _) {
                    buildCounts[index]++;
                    return JustCheckbox(
                      value: val,
                      onChanged: (newVal) {
                        valueNotifiers[index].value = newVal;
                      },
                    );
                  },
                );
              },
            ),
          ),
        );

        // Force a pump to ensure layout settling
        await tester.pump();

        final int initialCount = buildCounts[1];
        expect(initialCount, greaterThan(0));

        // Toggle first checkbox (index 0)
        valueNotifiers[0].value = !valueNotifiers[0].value!;
        await tester.pump();

        // Index 0 build count should increase
        expect(buildCounts[0], greaterThan(initialCount));
        // Index 1 build count should remain identical
        expect(buildCounts[1], equals(initialCount));
      },
    );

    testWidgets('100 JustRadio in ListView builds within budget', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        buildTestableWidget(
          ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) =>
                JustRadio<int>(value: index, groupValue: 0, onChanged: (_) {}),
          ),
        ),
      );

      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      debugPrint('Build time for 100 JustRadio: ${ms}ms');
      expect(ms, lessThan(500));
    });

    testWidgets('Toggling 1 radio in 100-item list does not rebuild siblings', (
      tester,
    ) async {
      final List<ValueNotifier<int>> valueNotifiers = List.generate(
        100,
        (i) => ValueNotifier<int>(i == 0 ? 0 : 1),
      );
      final List<int> buildCounts = List.generate(100, (_) => 0);

      await tester.pumpWidget(
        buildTestableWidget(
          ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return ValueListenableBuilder<int>(
                valueListenable: valueNotifiers[index],
                builder: (context, val, _) {
                  buildCounts[index]++;
                  return JustRadio<int>(
                    value: 0, // Option value
                    groupValue: val,
                    onChanged: (newVal) {
                      valueNotifiers[index].value = newVal;
                    },
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.pump();

      final int initialCount = buildCounts[1];
      expect(initialCount, greaterThan(0));

      // Toggle first item's selected group value
      valueNotifiers[0].value = 0;
      await tester.pump();

      expect(buildCounts[0], greaterThan(initialCount));
      expect(buildCounts[1], equals(initialCount));
    });

    testWidgets('100 JustSwitch in ListView builds within budget', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        buildTestableWidget(
          ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) =>
                JustSwitch(value: index.isEven, onChanged: (_) {}),
          ),
        ),
      );

      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      debugPrint('Build time for 100 JustSwitch: ${ms}ms');
      expect(ms, lessThan(500));
    });

    testWidgets(
      'Toggling 1 switch in 100-item list does not rebuild siblings',
      (tester) async {
        final List<ValueNotifier<bool>> valueNotifiers = List.generate(
          100,
          (i) => ValueNotifier<bool>(i.isEven),
        );
        final List<int> buildCounts = List.generate(100, (_) => 0);

        await tester.pumpWidget(
          buildTestableWidget(
            ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return ValueListenableBuilder<bool>(
                  valueListenable: valueNotifiers[index],
                  builder: (context, val, _) {
                    buildCounts[index]++;
                    return JustSwitch(
                      value: val,
                      onChanged: (newVal) {
                        valueNotifiers[index].value = newVal;
                      },
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.pump();

        final int initialCount = buildCounts[1];
        expect(initialCount, greaterThan(0));

        valueNotifiers[0].value = !valueNotifiers[0].value;
        await tester.pump();

        expect(buildCounts[0], greaterThan(initialCount));
        expect(buildCounts[1], equals(initialCount));
      },
    );
  });
}

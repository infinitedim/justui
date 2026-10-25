import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The node that has keyboard focus now.
FocusNode? get focused => FocusManager.instance.primaryFocus;

/// The focus node that owns the widget [finder] finds (its nearest [Focus]).
FocusNode nodeOf(WidgetTester tester, Finder finder) =>
    Focus.of(tester.element(finder));

/// Presses [key] and settles.
Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

/// Presses Shift+Tab and settles.
Future<void> shiftTab(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await press(tester, LogicalKeyboardKey.tab);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
}

/// Presses Tab until focus wraps back to the first stop and returns the
/// stops in order. A scene with no stops returns the route scope alone.
///
/// In the VM the route scope has no parent scope, so after the last stop Tab
/// wraps to the first one; on the web the same edge leaves the view
/// (`TraversalEdgeBehavior.leaveFlutterView`). Wrapping proves no stop keeps
/// Tab for itself, which is what a keyboard trap would do (AC12).
Future<List<FocusNode>> tabStops(WidgetTester tester, {int max = 80}) async {
  final List<FocusNode> stops = <FocusNode>[];
  for (int i = 0; i < max; i++) {
    await press(tester, LogicalKeyboardKey.tab);
    final FocusNode node = focused!;
    if (stops.isNotEmpty && node == stops.first) return stops;
    expect(stops, isNot(contains(node)), reason: 'Tab cycled inside the scene');
    stops.add(node);
  }
  fail('Tab did not wrap after ${stops.length} stops');
}

/// Presses Tab until [target] has focus; fails after [max] presses.
Future<void> tabTo(
  WidgetTester tester,
  FocusNode target, {
  int max = 60,
}) async {
  for (int i = 0; i < max; i++) {
    await press(tester, LogicalKeyboardKey.tab);
    if (focused == target) return;
  }
  fail('Tab did not reach $target in $max presses');
}

/// Focuses [stop], presses [key] and settles; returns whether it was handled.
Future<bool> activate(
  WidgetTester tester,
  FocusNode stop, [
  LogicalKeyboardKey key = LogicalKeyboardKey.enter,
]) async {
  stop.requestFocus();
  await tester.pump();
  final bool handled = await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
  return handled;
}

/// Whether the scene has no Tab stop of its own: Tab only reaches the
/// route scope.
Future<void> expectNoStops(WidgetTester tester) async {
  final List<FocusNode> stops = await tabStops(tester);
  expect(stops.single, isA<FocusScopeNode>());
}

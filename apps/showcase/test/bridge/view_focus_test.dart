// ignore_for_file: implementation_imports
import 'dart:ui' show ViewFocusDirection, ViewFocusEvent, ViewFocusState;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:showcase/bridge/bridge.dart';
import 'package:showcase/bridge/view_host.dart';

import '../support/fake_bridge.dart';
import '../support/fake_view.dart';

Map<String, Object?> _config(String scene) => <String, Object?>{
  'scene': scene,
  'preset': 'default',
  'theme': 'light',
  'locale': 'en',
};

/// The docs 404 shows several live parts. Each view's route takes the
/// startup autofocus in turn, so the last view mounted holds the primary
/// focus; Tab into an earlier view must still land on its first control,
/// not on an empty scope (DOM focus would stay on the flutter-view).
void main() {
  tearDown(() => debugBridgePlatform = null);

  Future<int> pumpTwoViews(WidgetTester tester) async {
    final int buttonView = tester.view.viewId;
    debugBridgePlatform = FakeBridgePlatform(<int, Object?>{
      buttonView: _config('button'),
      100: _config('badge'),
    });
    await tester.pumpWidget(
      ViewCollection(
        views: <Widget>[
          View(
            view: tester.view,
            child: ViewHost(viewId: buttonView),
          ),
          View(view: FakeView(tester.view), child: const ViewHost(viewId: 100)),
        ],
      ),
      wrapWithView: false,
    );
    await tester.pumpAndSettle();
    return buttonView;
  }

  Future<void> focusView(
    WidgetTester tester,
    int viewId,
    ViewFocusDirection direction,
  ) async {
    tester.binding.handleViewFocusChanged(
      ViewFocusEvent(
        viewId: viewId,
        state: ViewFocusState.focused,
        direction: direction,
      ),
    );
    await tester.pumpAndSettle();
  }

  bool onButton() {
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    return primary is! FocusScopeNode &&
        primary?.context?.findAncestorWidgetOfExactType<JustButton>() != null;
  }

  for (final ViewFocusDirection direction in <ViewFocusDirection>[
    .forward,
    .backward,
  ]) {
    testWidgets('Tab into a view lands on its control ($direction)', (
      WidgetTester tester,
    ) async {
      final int buttonView = await pumpTwoViews(tester);
      await focusView(tester, buttonView, direction);
      expect(
        onButton(),
        isTrue,
        reason: '${FocusManager.instance.primaryFocus}',
      );
    });
  }
}

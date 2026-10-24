import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';

/// Runs before every test file in this package.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadBridgeFonts();
  await testMain();
}

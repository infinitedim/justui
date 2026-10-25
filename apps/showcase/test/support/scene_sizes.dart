import 'package:flutter/widgets.dart' show Size;

/// The view size each live scene is locked at in its goldens and keyboard
/// tests: small, but large enough that nothing clips.
/// `test/goldens/scenes_golden_test.dart` checks every scene has one.
const Map<String, Size> sceneSizes = <String, Size>{
  // Actions
  'button': Size(320, 160),
  'icon-button': Size(160, 96),
  // Inputs
  'input': Size(320, 160),
  'radio': Size(320, 160),
  'radio-group': Size(320, 160),
  'switch': Size(320, 160),
  'slider': Size(320, 160),
  'date-picker': Size(372, 400),
  'date-range-picker': Size(372, 400),
  // Navigation
  'breadcrumb': Size(320, 96),
  // Display
  'accordion': Size(272, 170),
  'carousel': Size(280, 168),
  'avatar': Size(240, 96),
  'avatar-group': Size(200, 96),
  'badge': Size(200, 80),
  'card': Size(320, 160),
  'progress': Size(280, 96),
  'skeleton': Size(260, 96),
  'table': Size(320, 160),
  // Layout
  'separator': Size(240, 80),
  'resizable': Size(260, 110),
};

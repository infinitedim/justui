import 'package:flutter/widgets.dart';

import 'strings.dart';

/// What a scene gets to build its demo.
class const SceneContext({
  /// Copy for the active locale.
  required final KitStrings strings,

  /// Validated scene props (playground controls); empty for most scenes.
  final Map<String, Object> props = const <String, Object>{},
});

/// Builds the demo for one part. Scenes mirror the docs `KitPart` of the
/// same slug (`apps/docs/src/components/runner-kit/kit-part/kit-part.tsx`),
/// so swapping the React fallback for the live view does not change content.
typedef SceneBuilder = Widget Function(
  BuildContext context,
  SceneContext scene,
);

import 'package:flutter/semantics.dart' show SemanticsBinding, SemanticsHandle;
import 'package:flutter/widgets.dart';

import 'bridge/multi_view_app.dart';
import 'bridge/view_host.dart';

/// Keeps the semantics tree alive for the whole session.
late final SemanticsHandle semanticsHandle;

/// Entry point of the bridge. The docs page loads the engine in multi-view
/// mode and adds one view per live part; there is no implicit view, so this
/// uses [runWidget] instead of `runApp`.
void main() {
  runWidget(
    MultiViewApp(viewBuilder: (int viewId) => ViewHost(viewId: viewId)),
  );
  // Screen readers, axe and the docs e2e tests need the DOM semantics tree
  // without the hidden "Enable accessibility" button.
  semanticsHandle = SemanticsBinding.instance.ensureSemantics();
}

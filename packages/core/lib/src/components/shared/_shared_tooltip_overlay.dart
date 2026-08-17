import 'package:flutter/widgets.dart';

import '../tooltip/just_tooltip.dart';

/// Legacy overlay tooltip wrapper that delegates to unified [JustTooltip].
class const JustTooltipOverlay({
  required final String message,
  required final Widget child,
  super.key,
  final OverlayPortalController? controller,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JustTooltip(
      message: message,
      preferredPosition: .right,
      controller: controller,
      child: child,
    );
  }
}

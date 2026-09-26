// justui-meta: registry=66dee601399ca4bd94b62308ab8396dbbba379943b91d00a9ff6ec57dba4e063 local=7c99b2c5e774c9c79079ab8074427057e64057f030a29895f26ab089e5eb7dcb
import 'package:flutter/widgets.dart';

import '../tooltip/just_tooltip.dart';

/// Legacy overlay tooltip wrapper that delegates to unified [JustTooltip].
class JustTooltipOverlay extends StatelessWidget {
  final String message;
  final Widget child;
  final OverlayPortalController? controller;

  const JustTooltipOverlay({
    required this.message,
    required this.child,
    super.key,
    this.controller,
  });

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

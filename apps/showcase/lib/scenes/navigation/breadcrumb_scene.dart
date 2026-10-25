// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/breadcrumb/just_breadcrumb.dart';

import '../scene.dart';

/// Part 06, breadcrumb: the trail `lib > widgets > button` with `button` as
/// the current page, like `KitPart` `breadcrumb` (`KitBreadcrumb`).
///
/// The trail items are plain text as in React (no links), so the scene has
/// no tab stop. The chevron separator is the React one; the path segments
/// are code names and stay literal.
Widget breadcrumbScene(BuildContext context, SceneContext scene) {
  return Semantics(
    label: scene.strings.text('breadcrumb'),
    container: true,
    explicitChildNodes: true,
    child: JustBreadcrumb(
      separator: Icon(
        Icons.chevron_right,
        size: 14,
        color: context.justColors.textSecondary,
      ),
      items: const <JustBreadcrumbItem>[
        JustBreadcrumbItem(label: 'lib'),
        JustBreadcrumbItem(label: 'widgets'),
        JustBreadcrumbItem(label: 'button'),
      ],
    ),
  );
}

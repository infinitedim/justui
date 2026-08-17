// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/breadcrumb/just_breadcrumb.dart';

@widgetbook.UseCase(name: 'Default Breadcrumb', type: JustBreadcrumb)
Widget buildJustBreadcrumbDefaultUseCase(BuildContext context) {
  final maxItems = context.knobs.double
      .slider(label: 'Max Items (0 = All)', initialValue: 0, min: 0, max: 5)
      .toInt();

  return JustBreadcrumb(
    maxItems: maxItems > 0 ? maxItems : null,
    items: [
      JustBreadcrumbItem(label: 'Home', onTap: () {}),
      JustBreadcrumbItem(label: 'Components', onTap: () {}),
      JustBreadcrumbItem(label: 'Navigation', onTap: () {}),
      const JustBreadcrumbItem(label: 'Breadcrumb'),
    ],
  );
}

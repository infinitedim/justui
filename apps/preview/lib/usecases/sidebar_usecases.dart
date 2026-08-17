// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/sidebar/just_sidebar.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_variants.dart';

@widgetbook.UseCase(name: 'Default Sidebar', type: JustSidebar)
Widget buildJustSidebarDefaultUseCase(BuildContext context) {
  final isCollapsed = context.knobs.boolean(
    label: 'Collapsed',
    initialValue: false,
  );
  final variant = context.knobs.object.dropdown<JustSidebarVariant>(
    label: 'Variant',
    options: JustSidebarVariant.values,
    initialOption: JustSidebarVariant.default_,
  );

  return Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      height: double.infinity,
      child: JustSidebar(
        isCollapsed: isCollapsed,
        variant: variant,
        header: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'JustUI Admin',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
        ),
        items: const [
          JustSidebarItem(
            label: 'Dashboard',
            icon: Icon(IconData(0xe1b0, fontFamily: 'MaterialIcons')),
          ),
          JustSidebarItem(
            label: 'Analytics',
            icon: Icon(IconData(0xe0b9, fontFamily: 'MaterialIcons')),
          ),
          JustSidebarItem(
            label: 'Settings',
            icon: Icon(IconData(0xe57f, fontFamily: 'MaterialIcons')),
          ),
        ],
      ),
    ),
  );
}

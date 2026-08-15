// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/tabs/just_tabs.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs_variants.dart';

@widgetbook.UseCase(name: 'Default Tabs', type: JustTabs)
Widget buildJustTabsDefaultUseCase(BuildContext context) {
  final variant = context.knobs.object.dropdown<JustTabVariant>(
    label: 'Variant',
    options: JustTabVariant.values,
    initialOption: JustTabVariant.line,
  );

  return SizedBox(
    height: 300.0,
    width: 400.0,
    child: JustTabs(
      variant: variant,
      tabs: const [
        JustTab(
          label: 'Account',
          content: Center(child: Text('Account Settings Content')),
        ),
        JustTab(
          label: 'Password',
          content: Center(child: Text('Password Security Content')),
        ),
        JustTab(
          label: 'Notifications',
          content: Center(child: Text('Notification Preferences Content')),
        ),
      ],
    ),
  );
}

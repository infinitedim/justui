// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_variants.dart';

@widgetbook.UseCase(name: 'Default Bottom Nav', type: JustBottomNav)
Widget buildJustBottomNavDefaultUseCase(BuildContext context) {
  final variant = context.knobs.object.dropdown<JustBottomNavVariant>(
    label: 'Variant',
    options: JustBottomNavVariant.values,
    initialOption: JustBottomNavVariant.fixed,
  );
  final selectedIndex = context.knobs.double
      .slider(label: 'Selected Index', initialValue: 0, min: 0, max: 2)
      .toInt();

  return Align(
    alignment: Alignment.bottomCenter,
    child: JustBottomNav(
      variant: variant,
      selectedIndex: selectedIndex,
      onItemSelected: (val) {},
      items: const [
        JustBottomNavItem(
          label: 'Home',
          icon: Icon(IconData(0xe318, fontFamily: 'MaterialIcons')),
        ),
        JustBottomNavItem(
          label: 'Search',
          icon: Icon(IconData(0xe554, fontFamily: 'MaterialIcons')),
        ),
        JustBottomNavItem(
          label: 'Settings',
          icon: Icon(IconData(0xe57f, fontFamily: 'MaterialIcons')),
        ),
      ],
    ),
  );
}

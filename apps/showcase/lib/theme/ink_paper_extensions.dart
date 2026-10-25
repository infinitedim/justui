// ignore_for_file: implementation_imports
import 'package:flutter/material.dart' show ThemeExtension;
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/accordion/just_accordion_theme.dart';
import 'package:just_ui_core/src/components/bottom_nav/just_bottom_nav_theme.dart';
import 'package:just_ui_core/src/components/breadcrumb/just_breadcrumb_theme.dart';
import 'package:just_ui_core/src/components/card/just_card_theme.dart';
import 'package:just_ui_core/src/components/carousel/just_carousel_theme.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox_theme.dart';
import 'package:just_ui_core/src/components/date_picker/just_date_picker_theme.dart';
import 'package:just_ui_core/src/components/dialog/just_dialog_theme.dart';
import 'package:just_ui_core/src/components/input/just_input_theme.dart';
import 'package:just_ui_core/src/components/progress/just_progress_theme.dart';
import 'package:just_ui_core/src/components/radio/just_radio_theme.dart';
import 'package:just_ui_core/src/components/resizable/just_resizable_theme.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area_theme.dart';
import 'package:just_ui_core/src/components/select/just_select_theme.dart';
import 'package:just_ui_core/src/components/separator/just_separator_theme.dart';
import 'package:just_ui_core/src/components/sheet/just_sheet_theme.dart';
import 'package:just_ui_core/src/components/sidebar/just_sidebar_theme.dart';
import 'package:just_ui_core/src/components/skeleton/just_skeleton_theme.dart';
import 'package:just_ui_core/src/components/slider/just_slider_theme.dart';
import 'package:just_ui_core/src/components/switch/just_switch_theme.dart';
import 'package:just_ui_core/src/components/table/just_table_theme.dart';
import 'package:just_ui_core/src/components/tabs/just_tabs_theme.dart';
import 'package:just_ui_core/src/components/time_picker/just_time_picker_theme.dart';
import 'package:just_ui_core/src/components/toast/just_toast_theme.dart';
import 'package:just_ui_core/src/components/toggle/just_toggle_theme.dart';
import 'package:just_ui_core/src/components/tooltip/just_tooltip_theme.dart';

import 'package:just_ui_core/src/components/button/just_button_theme.dart';

import 'extensions/actions_overrides.dart';
import 'extensions/display_overrides.dart';
import 'extensions/inputs_overrides.dart';
import 'extensions/layout_overrides.dart';
import 'extensions/navigation_overrides.dart';
import 'extensions/overlays_overrides.dart';
import 'ink_paper_tokens.dart';

/// Every component theme extension for one preset and mode.
///
/// Core's `toThemeData()` registers none: the CLI writes them at the
/// `// CLI:REGISTER_EXTENSIONS` anchor of the user's copy. The bridge must
/// render what users get, so it registers the same set (locked by
/// `test/theme/extensions_drift_test.dart`) and swaps in an Ink and Paper
/// override where one exists in `extensions/`.
List<ThemeExtension<dynamic>> inkPaperExtensions(
  JustThemePreset preset,
  InkPaperRoles roles,
) {
  final Map<Object, ThemeExtension<dynamic>> overrides =
      <Object, ThemeExtension<dynamic>>{};
  for (final List<ThemeExtension<dynamic>> group
      in <List<ThemeExtension<dynamic>>>[
        actionsOverrides(preset, roles),
        inputsOverrides(preset, roles),
        navigationOverrides(preset, roles),
        overlaysOverrides(preset, roles),
        displayOverrides(preset, roles),
        layoutOverrides(preset, roles),
      ]) {
    for (final ThemeExtension<dynamic> e in group) {
      overrides[e.type] = e;
    }
  }
  return _coreDefaults
      .map((ThemeExtension<dynamic> e) => overrides[e.type] ?? e)
      .toList();
}

/// What the CLI registers at `// CLI:REGISTER_EXTENSIONS`.
const List<ThemeExtension<dynamic>> _coreDefaults = <ThemeExtension<dynamic>>[
  JustButtonTheme.defaults,
  JustInputTheme.defaults,
  JustCheckboxTheme.defaults,
  JustRadioTheme.defaults,
  JustSwitchTheme.defaults,
  JustCardTheme.defaults,
  JustSeparatorTheme.defaults,
  JustScrollAreaTheme.defaults,
  JustResizableTheme.defaults,
  JustCarouselTheme.defaults,
  JustSkeletonTheme.defaults,
  JustSliderTheme.defaults,
  JustBreadcrumbTheme.defaults,
  JustTabsTheme.defaults,
  JustBottomNavTheme.defaults,
  JustTooltipTheme.defaults,
  JustSidebarTheme.defaults,
  JustToastTheme.defaults,
  JustDialogTheme.defaults,
  JustSheetTheme.defaults,
  JustSelectTheme.defaults,
  JustProgressTheme.defaults,
  JustAccordionTheme.defaults,
  JustToggleTheme.defaults,
  JustTableTheme.defaults,
  JustDatePickerTheme.defaults,
  JustTimePickerTheme.defaults,
];

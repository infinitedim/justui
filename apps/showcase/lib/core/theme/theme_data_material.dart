import 'package:flutter/material.dart';
import 'package:showcase/widgets/accordion/just_accordion_theme.dart';
import 'package:showcase/widgets/bottom-nav/just_bottom_nav_theme.dart';
import 'package:showcase/widgets/breadcrumb/just_breadcrumb_theme.dart';
import 'package:showcase/widgets/button/just_button_theme.dart';
import 'package:showcase/widgets/card/just_card_theme.dart';
import 'package:showcase/widgets/carousel/just_carousel_theme.dart';
import 'package:showcase/widgets/checkbox/just_checkbox_theme.dart';
import 'package:showcase/widgets/date-picker/just_date_picker_theme.dart';
import 'package:showcase/widgets/dialog/just_dialog_theme.dart';
import 'package:showcase/widgets/input/just_input_theme.dart';
import 'package:showcase/widgets/progress/just_progress_theme.dart';
import 'package:showcase/widgets/radio/just_radio_theme.dart';
import 'package:showcase/widgets/resizable/just_resizable_theme.dart';
import 'package:showcase/widgets/select/just_select_theme.dart';
import 'package:showcase/widgets/separator/just_separator_theme.dart';
import 'package:showcase/widgets/sheet/just_sheet_theme.dart';
import 'package:showcase/widgets/sidebar/just_sidebar_theme.dart';
import 'package:showcase/widgets/skeleton/just_skeleton_theme.dart';
import 'package:showcase/widgets/slider/just_slider_theme.dart';
import 'package:showcase/widgets/switch/just_switch_theme.dart';
import 'package:showcase/widgets/table/just_table_theme.dart';
import 'package:showcase/widgets/tabs/just_tabs_theme.dart';
import 'package:showcase/widgets/time-picker/just_time_picker_theme.dart';
import 'package:showcase/widgets/toast/just_toast_theme.dart';
import 'package:showcase/widgets/toggle/just_toggle_theme.dart';
import 'package:showcase/widgets/tooltip/just_tooltip_theme.dart';

import 'theme_data.dart';

final Expando<ThemeData> _themeDataCache = Expando<ThemeData>();

/// Material ThemeData extension to bridge JustUI theme tokens to Material widgets.
extension JustThemeDataMaterialExtension on JustThemeData {
  /// Converts this [JustThemeData] configuration into Flutter [ThemeData].
  /// Caches the created [ThemeData] instance to prevent recalculation overhead.
  ThemeData toThemeData() {
    return _themeDataCache[this] ??= _buildMaterialTheme();
  }

  ThemeData _buildMaterialTheme() {
    final isDark = colors.background.computeLuminance() < 0.5;
    final Brightness brightness = isDark ? .dark : .light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: const [
        JustAccordionTheme.defaults,
        JustBottomNavTheme.defaults,
        JustBreadcrumbTheme.defaults,
        JustButtonTheme.defaults,
        JustCardTheme.defaults,
        JustCarouselTheme.defaults,
        JustCheckboxTheme.defaults,
        JustDatePickerTheme.defaults,
        JustDialogTheme.defaults,
        JustInputTheme.defaults,
        JustProgressTheme.defaults,
        JustRadioTheme.defaults,
        JustResizableTheme.defaults,
        JustSelectTheme.defaults,
        JustSeparatorTheme.defaults,
        JustSheetTheme.defaults,
        JustSidebarTheme.defaults,
        JustSkeletonTheme.defaults,
        JustSliderTheme.defaults,
        JustSwitchTheme.defaults,
        JustTableTheme.defaults,
        JustTabsTheme.defaults,
        JustTimePickerTheme.defaults,
        JustToastTheme.defaults,
        JustToggleTheme.defaults,
        JustTooltipTheme.defaults,
        // CLI:REGISTER_EXTENSIONS
      ],
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.card,
      dividerColor: colors.borderDefault,
      dialogTheme: DialogThemeData(backgroundColor: colors.elevated),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.borderFocus,
        onPrimary: colors.textInverse,
        secondary: colors.borderFocus,
        onSecondary: colors.textInverse,
        error: colors.error,
        onError: colors.textInverse,
        surface: colors.card,
        onSurface: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0.0,
        titleTextStyle: typography.headingLg.copyWith(
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        actionsIconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: .all(radius.lg)),
        elevation: 0.0,
        color: colors.card,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.background,
        border: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderFocus, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: .all(radius.md),
          borderSide: BorderSide(color: colors.borderError, width: 2.0),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1.0,
        space: 1.0,
        color: colors.borderDefault,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: .all(radius.md)),
        padding: .symmetric(horizontal: spacing.md, vertical: spacing.sm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: .all(radius.md)),
          padding: .symmetric(horizontal: spacing.md, vertical: spacing.sm),
          textStyle: typography.bodyMd,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: .all(radius.md)),
          padding: .symmetric(horizontal: spacing.md, vertical: spacing.sm),
          textStyle: typography.bodyMd,
        ),
      ),
    );
  }
}

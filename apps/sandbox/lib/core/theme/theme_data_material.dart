import 'package:flutter/material.dart';
import 'package:sandbox/widgets/button/just_button_theme.dart';
import 'package:sandbox/widgets/input/just_input_theme.dart';
import 'package:sandbox/widgets/checkbox/just_checkbox_theme.dart';
import 'package:sandbox/widgets/radio/just_radio_theme.dart';
import 'package:sandbox/widgets/switch/just_switch_theme.dart';
import 'package:sandbox/widgets/card/just_card_theme.dart';
import 'package:sandbox/widgets/separator/just_separator_theme.dart';
import 'package:sandbox/widgets/scroll-area/just_scroll_area_theme.dart';
import 'package:sandbox/widgets/resizable/just_resizable_theme.dart';
import 'package:sandbox/widgets/carousel/just_carousel_theme.dart';
import 'package:sandbox/widgets/skeleton/just_skeleton_theme.dart';
import 'package:sandbox/widgets/slider/just_slider_theme.dart';
import 'package:sandbox/widgets/breadcrumb/just_breadcrumb_theme.dart';
import 'package:sandbox/widgets/tabs/just_tabs_theme.dart';
import 'package:sandbox/widgets/bottom-nav/just_bottom_nav_theme.dart';
import 'package:sandbox/widgets/tooltip/just_tooltip_theme.dart';
import 'package:sandbox/widgets/sidebar/just_sidebar_theme.dart';
import 'package:sandbox/widgets/toast/just_toast_theme.dart';
import 'package:sandbox/widgets/dialog/just_dialog_theme.dart';
import 'package:sandbox/widgets/sheet/just_sheet_theme.dart';
import 'package:sandbox/widgets/select/just_select_theme.dart';
import 'package:sandbox/widgets/progress/just_progress_theme.dart';
import 'package:sandbox/widgets/accordion/just_accordion_theme.dart';
import 'package:sandbox/widgets/toggle/just_toggle_theme.dart';
import 'package:sandbox/widgets/table/just_table_theme.dart';
import 'package:sandbox/widgets/date-picker/just_date_picker_theme.dart';
import 'package:sandbox/widgets/time-picker/just_time_picker_theme.dart';

import 'theme_data.dart';

final Expando<ThemeData> _themeDataCache = Expando<ThemeData>();

/// Material ThemeData extension to bridge JustUI theme tokens to Material widgets.
extension JustThemeDataMaterialExtension on JustThemeData {
  /// Converts this [JustThemeData] configuration into Flutter [ThemeData].
  /// Caches the created [ThemeData] instance to prevent recalculation overhead.
  ThemeData toThemeData({
    Iterable<ThemeExtension<dynamic>>? additionalExtensions,
  }) {
    if (additionalExtensions == null || additionalExtensions.isEmpty) {
      return _themeDataCache[this] ??= _buildMaterialTheme();
    }
    final ThemeData base = _themeDataCache[this] ??= _buildMaterialTheme();
    final List<ThemeExtension<dynamic>> combined =
        base.extensions.values.toList()..addAll(additionalExtensions);
    return base.copyWith(extensions: combined);
  }

  ThemeData _buildMaterialTheme() {
    final bool isDark = colors.background.computeLuminance() < 0.5;
    final Brightness brightness = isDark ? .dark : .light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: const <ThemeExtension<dynamic>>[
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

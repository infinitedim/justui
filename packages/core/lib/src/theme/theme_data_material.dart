import 'package:flutter/material.dart';

import 'theme_data.dart';
import '../components/button/just_button_theme.dart';
import '../components/input/just_input_theme.dart';
import '../components/checkbox/just_checkbox_theme.dart';
import '../components/radio/just_radio_theme.dart';
import '../components/switch/just_switch_theme.dart';
import '../components/card/just_card_theme.dart';
import '../components/separator/just_separator_theme.dart';
import '../components/skeleton/just_skeleton_theme.dart';
import '../components/scroll/just_scroll_area_theme.dart';
import '../components/breadcrumb/just_breadcrumb_theme.dart';
import '../components/bottom_nav/just_bottom_nav_theme.dart';
import '../components/sidebar/just_sidebar_theme.dart';
import '../components/tabs/just_tabs_theme.dart';
import '../components/toast/just_toast_theme.dart';
import '../components/dialog/just_dialog_theme.dart';
import '../components/sheet/just_sheet_theme.dart';
import '../components/tooltip/just_tooltip_theme.dart';

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
      extensions: const <ThemeExtension<dynamic>>[
        JustButtonTheme.defaults,
        JustCardTheme.defaults,
        JustInputTheme.defaults,
        JustCheckboxTheme.defaults,
        JustRadioTheme.defaults,
        JustSwitchTheme.defaults,
        JustTabsTheme.defaults,
        JustSeparatorTheme.defaults,
        JustSkeletonTheme.defaults,
        JustScrollAreaTheme.defaults,
        JustBreadcrumbTheme.defaults,
        JustBottomNavTheme.defaults,
        JustSidebarTheme.defaults,
        JustToastTheme.defaults,
        JustDialogTheme.defaults,
        JustSheetTheme.defaults,
        JustTooltipTheme.defaults,
      ],
    );
  }
}

// ignore_for_file: implementation_imports
import 'package:just_ui_core/src/components/date_picker/just_date_picker_variants.dart';

import '../scene.dart';

/// Year of the demo month.
///
/// The React demos show October without a year. Core marks today with a
/// ring from `DateTime.now()` and has no way to pass a fixed "today", so a
/// demo month that contains the current day would change the goldens every
/// day. A past October keeps them stable.
const int _demoYear = 2025;

/// Day [day] of the demo month (October).
DateTime demoDay(int day) => DateTime(_demoYear, 10, day);

/// Core's EN calendar locale with October taken from the page's `month`
/// string, so the header follows the docs locale like the React demo.
JustDatePickerLocale demoLocale(SceneContext scene) {
  const JustDatePickerLocale en = JustDatePickerLocale();
  final List<String> months = List<String>.of(en.monthNames);
  months[9] = scene.strings.text('month');
  return JustDatePickerLocale(
    monthNames: months,
    shortMonthNames: en.shortMonthNames,
    weekdayHeaders: en.weekdayHeaders,
  );
}

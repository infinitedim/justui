import 'package:flutter_test/flutter_test.dart';

import '../support/golden_harness.dart';
import '../support/scene_sizes.dart';

/// The ID copy the docs send (`kitTranslations.id`), for the keys these
/// scenes read.
const Map<String, Object> _id = <String, Object>{
  'month': 'Oktober',
  'weekdays': <String>['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
  'dayLabel': '{day} {month} {year}',
  'daysLabel': 'Hari di bulan Oktober',
  'slide': 'Slide {index} dari {total}',
  'slideAria': 'Ke slide {index}',
  'slidesLabel': 'Slide',
  'volume': 'Volume',
  'files': 'File',
  'editor': 'Editor',
  'splitterLabel': 'Pemisah panel {index}',
  'tabs': <String>['Akun', 'Tagihan', 'Tim'],
  'tabsLabel': 'Bagian pengaturan',
  'bottomNav': <String>['Beranda', 'Cari', 'Profil'],
  'bottomNavLabel': 'Navigasi aplikasi',
  'sidebar': <String>['Ringkasan', 'Komponen', 'Pengaturan'],
  'sidebarLabel': 'Bagian',
  'scrollAreaLabel': 'Daftar path komponen yang bisa digulir',
  'timePickerLabel': 'Pilih waktu',
  'hourLabel': 'Jam',
  'minuteLabel': 'Menit',
  'periodLabel': 'Periode',
  'amLabel': 'AM',
  'pmLabel': 'PM',
  'cancel': 'Batal',
  'save': 'Simpan',
  'dialModeTooltip': 'Ganti ke mode dial',
  'inputModeTooltip': 'Ganti ke mode input',
  'spinnerModeTooltip': 'Ganti ke mode spinner',
  'nextValueLabel': 'Nilai berikutnya',
  'previousValueLabel': 'Nilai sebelumnya',
};

/// Calendars and carousel dots speak the page's language: no core English
/// reaches the screen or a screen reader on an ID page.
void main() {
  Future<SemanticsHandle> pumpId(WidgetTester tester, String scene) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpScene(
      tester,
      scene: scene,
      preset: .default_,
      mode: .light,
      size: sceneSizes[scene]!,
      strings: _id,
    );
    return handle;
  }

  for (final String scene in <String>['date-picker', 'date-range-picker']) {
    testWidgets('$scene in ID', (WidgetTester tester) async {
      final SemanticsHandle handle = await pumpId(tester, scene);
      expect(find.text('Oktober'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);
      expect(find.text('Sun'), findsNothing);
      expect(find.bySemanticsLabel(RegExp('^20 Oktober 2025')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Day ')), findsNothing);
      handle.dispose();
    });
  }

  testWidgets('carousel in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'carousel');
    expect(find.text('Slide 1 dari 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Ke slide 2'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Slide \d$')), findsNothing);
    handle.dispose();
  });

  testWidgets('slider in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'slider');
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.bySemanticsLabel('Volume'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('resizable in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'resizable');
    expect(find.text('File'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.text('Files'), findsNothing);
    expect(find.bySemanticsLabel('Pemisah panel 1'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Splitter divider')), findsNothing);
    handle.dispose();
  });

  testWidgets('tabs in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'tabs');
    expect(find.text('Akun'), findsWidgets);
    expect(find.text('Tagihan'), findsWidgets);
    expect(find.text('Tim'), findsWidgets);
    expect(find.text('Account'), findsNothing);
    expect(find.bySemanticsLabel('Bagian pengaturan'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('bottom-nav in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'bottom-nav');
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.bySemanticsLabel('Navigasi aplikasi'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('sidebar in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'sidebar');
    expect(find.text('Ringkasan'), findsOneWidget);
    expect(find.text('Komponen'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Overview'), findsNothing);
    expect(find.bySemanticsLabel('Bagian'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('scroll-area in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'scroll-area');
    expect(
      find.bySemanticsLabel('Daftar path komponen yang bisa digulir'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Scrollable component paths'), findsNothing);
    handle.dispose();
  });

  testWidgets('time-picker in ID', (WidgetTester tester) async {
    final SemanticsHandle handle = await pumpId(tester, 'time-picker');
    expect(find.bySemanticsLabel('Pilih waktu'), findsOneWidget);
    expect(find.bySemanticsLabel('Jam: 09'), findsOneWidget);
    expect(find.bySemanticsLabel('Menit: 41'), findsOneWidget);
    expect(find.bySemanticsLabel('Ganti ke mode input'), findsNothing);
    expect(find.bySemanticsLabel('Jam'), findsOneWidget);
    expect(find.bySemanticsLabel('Menit'), findsOneWidget);
    expect(find.bySemanticsLabel('Periode'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Hour')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('^Minute')), findsNothing);
    expect(find.bySemanticsLabel('Period'), findsNothing);
    handle.dispose();
  });
}

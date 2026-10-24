import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;

/// Families the bridge declares, with the files that back them.
const Map<String, List<String>> bridgeFontFiles = <String, List<String>>{
  'PlusJakartaSans': <String>[
    'PlusJakartaSans-Regular.ttf',
    'PlusJakartaSans-Medium.ttf',
    'PlusJakartaSans-SemiBold.ttf',
    'PlusJakartaSans-Bold.ttf',
  ],
  'IBMPlexMono': <String>['IBMPlexMono-Regular.ttf', 'IBMPlexMono-Medium.ttf'],
  'Roboto': <String>['PlusJakartaSans-Regular.ttf'],
};

/// The font folder (the `assets/fonts` symlink into packages/tokens).
final Directory fontsDir = Directory('assets/fonts');

/// Loads the real font files so goldens show the real glyphs, not Ahem.
Future<void> loadBridgeFonts() async {
  for (final MapEntry<String, List<String>> family in bridgeFontFiles.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String file in family.value) {
      final Uint8List bytes = File('${fontsDir.path}/$file').readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

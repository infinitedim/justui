import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/bridge/view_config.dart';
import 'package:showcase/theme/ink_paper_theme.dart';

void main() {
  group('parse', () {
    test('reads a full valid config', () {
      final ViewConfig? config = ViewConfig.parse(<String, Object?>{
        'scene': 'button',
        'preset': 'neobrutalism',
        'theme': 'dark',
        'locale': 'id',
        'strings': <String, Object?>{
          'saveChanges': 'Simpan perubahan',
          'tabs': <Object?>['Akun', 'Tagihan', 'Tim'],
        },
      });
      expect(config, isNotNull);
      expect(config!.scene, 'button');
      expect(config.preset, JustThemePreset.neobrutalism);
      expect(config.mode, InkPaperMode.dark);
      expect(config.locale, 'id');
      expect(config.strings['saveChanges'], 'Simpan perubahan');
      expect(config.strings['tabs'], <String>['Akun', 'Tagihan', 'Tim']);
    });

    test('rejects a missing or unknown scene', () {
      expect(ViewConfig.parse(null), isNull);
      expect(ViewConfig.parse('button'), isNull);
      expect(ViewConfig.parse(<String, Object?>{}), isNull);
      expect(ViewConfig.parse(<String, Object?>{'scene': 'nope'}), isNull);
      expect(ViewConfig.parse(<String, Object?>{'scene': 7}), isNull);
    });
  });

  group('merge', () {
    const ViewConfig base = ViewConfig(scene: 'button');

    test('keeps the previous value for invalid fields', () {
      final ViewConfig next = base.merge(<String, Object?>{
        'scene': 'card',
        'preset': 'material',
        'theme': 'sepia',
        'locale': 'fr',
        'strings': <String, Object?>{'saveChanges': 42},
        'props': <String, Object?>{'label': 'x' * 41},
      });
      expect(next.scene, 'button');
      expect(next.preset, JustThemePreset.default_);
      expect(next.mode, InkPaperMode.light);
      expect(next.locale, 'en');
      expect(next.strings, isEmpty);
      expect(next.props, isEmpty);
    });

    test('rejects control, bidi and zero-width characters in copy', () {
      for (final String bad in <String>['a\nb', 'a\u202Eb', 'a\u200Bb', '']) {
        final ViewConfig next = base.merge(<String, Object?>{
          'strings': <String, Object?>{'saveChanges': bad},
        });
        expect(next.strings, isEmpty, reason: 'accepted ${bad.codeUnits}');
      }
    });

    test('rejects bad keys and oversized maps', () {
      expect(
        base.merge(<String, Object?>{
          'strings': <String, Object?>{'__proto__': 'x'},
        }).strings,
        isEmpty,
      );
      expect(
        base.merge(<String, Object?>{
          'strings': <String, Object?>{for (int i = 0; i < 97; i++) 'k$i': 'v'},
        }).strings,
        isEmpty,
      );
    });

    test('props take booleans, finite numbers and short printable ASCII', () {
      final ViewConfig next = base.merge(<String, Object?>{
        'props': <String, Object?>{'loading': true, 'size': 2, 'label': 'Pay'},
      });
      expect(next.props, <String, Object>{
        'loading': true,
        'size': 2,
        'label': 'Pay',
      });
      expect(
        base.merge(<String, Object?>{
          'props': <String, Object?>{'label': 'Bayar \u00E9'},
        }).props,
        isEmpty,
      );
      expect(
        base.merge(<String, Object?>{
          'props': <String, Object?>{'size': double.nan},
        }).props,
        isEmpty,
      );
    });
  });
}

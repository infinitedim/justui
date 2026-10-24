import 'package:just_ui_core/just_ui_core.dart';

import '../scenes/scene_registry.dart';
import '../theme/ink_paper_theme.dart';

/// What one view renders, as validated from the page.
///
/// Everything here crosses the JS boundary, so nothing is trusted: a value is
/// taken only when it passes its whitelist, and an invalid value keeps the
/// previous one (`.agents/rules/security.md`, Flutter bridge). The page
/// validates the same shape with zod/mini before sending it.
class const ViewConfig({
  /// Registry slug of the scene; always a key of [sceneRegistry].
  required final String scene,

  /// Active preset.
  final JustThemePreset preset = .default_,

  /// Light or dark mode.
  final InkPaperMode mode = .light,

  /// Locale of [strings]; one of [locales].
  final String locale = 'en',

  /// Copy for the scene, keyed like the docs `KitDictionary`.
  final Map<String, Object> strings = const <String, Object>{},

  /// Scene props (playground controls).
  final Map<String, Object> props = const <String, Object>{},
}) {
  /// Locales the docs can send. Adding one (zh) is a data change only.
  static const Set<String> locales = <String>{'en', 'id'};

  /// Copy keys look like `saveChanges`.
  static final RegExp _key = RegExp(r'^[a-zA-Z][a-zA-Z0-9]{0,39}$');

  static const int _maxEntries = 96;
  static const int _maxListItems = 8;
  static const int _maxTextLength = 200;
  static const int _maxPropTextLength = 40;

  /// Parses the `config` object of a view's `initialData`, or returns null
  /// when it does not name a known scene.
  static ViewConfig? parse(Object? raw) {
    if (raw is! Map) return null;
    final Object? scene = raw['scene'];
    if (scene is! String || !sceneRegistry.containsKey(scene)) return null;
    return ViewConfig(scene: scene).merge(raw);
  }

  /// A copy with every valid field of [patch] applied. The scene of a view
  /// never changes.
  ViewConfig merge(Object? patch) {
    if (patch is! Map) return this;
    return ViewConfig(
      scene: scene,
      preset: _preset(patch['preset']) ?? preset,
      mode: _mode(patch['theme']) ?? mode,
      locale: _locale(patch['locale']) ?? locale,
      strings: _strings(patch['strings']) ?? strings,
      props: _props(patch['props']) ?? props,
    );
  }

  static JustThemePreset? _preset(Object? value) => switch (value) {
    'default' => .default_,
    'neobrutalism' => .neobrutalism,
    _ => null,
  };

  static InkPaperMode? _mode(Object? value) => switch (value) {
    'light' => .light,
    'dark' => .dark,
    _ => null,
  };

  static String? _locale(Object? value) =>
      value is String && locales.contains(value) ? value : null;

  static Map<String, Object>? _strings(Object? value) {
    if (value is! Map || value.length > _maxEntries) return null;
    final Map<String, Object> out = <String, Object>{};
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      final Object? key = entry.key;
      if (key is! String || !_key.hasMatch(key)) return null;
      final Object? text = _text(entry.value, _maxTextLength, asciiOnly: false);
      final Object? list = _textList(entry.value);
      if (text == null && list == null) return null;
      out[key] = text ?? list!;
    }
    return out;
  }

  static List<String>? _textList(Object? value) {
    if (value is! List || value.isEmpty || value.length > _maxListItems) {
      return null;
    }
    final List<String> out = <String>[];
    for (final Object? item in value) {
      final String? text = _text(item, _maxTextLength, asciiOnly: false);
      if (text == null) return null;
      out.add(text);
    }
    return List<String>.unmodifiable(out);
  }

  static Map<String, Object>? _props(Object? value) {
    if (value is! Map || value.length > _maxEntries) return null;
    final Map<String, Object> out = <String, Object>{};
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      final Object? key = entry.key;
      final Object? item = entry.value;
      if (key is! String || !_key.hasMatch(key)) return null;
      if (item is bool) {
        out[key] = item;
      } else if (item is num && item.isFinite) {
        out[key] = item;
      } else {
        final String? text = _text(item, _maxPropTextLength, asciiOnly: true);
        if (text == null) return null;
        out[key] = text;
      }
    }
    return out;
  }

  /// [value] when it is a non-empty string within [maxLength] that holds no
  /// control, bidi or zero-width characters (and only printable ASCII when
  /// [asciiOnly]); else null.
  static String? _text(
    Object? value,
    int maxLength, {
    required bool asciiOnly,
  }) {
    if (value is! String || value.isEmpty || value.length > maxLength) {
      return null;
    }
    for (final int unit in value.codeUnits) {
      final bool control = unit < 0x20 || (unit >= 0x7F && unit < 0xA0);
      final bool bidi =
          (unit >= 0x202A && unit <= 0x202E) ||
          (unit >= 0x2066 && unit <= 0x2069);
      final bool zeroWidth =
          (unit >= 0x200B && unit <= 0x200D) || unit == 0xFEFF;
      if (control || bidi || zeroWidth || (asciiOnly && unit > 0x7E)) {
        return null;
      }
    }
    return value;
  }
}

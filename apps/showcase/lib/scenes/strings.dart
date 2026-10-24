/// Copy shown inside the scenes.
///
/// The docs page sends its `KitDictionary` (`apps/docs/src/lib/kit-translations.ts`)
/// in each view's `initialData`, so EN, ID and later locales come from one
/// source. These EN defaults only cover standalone runs (the harness, tests)
/// and keys a page did not send.
class const KitStrings({
  /// Validated values from the page, keyed like `KitDictionary`.
  final Map<String, Object> values = const <String, Object>{},
}) {
  /// EN defaults for the keys the scenes read.
  static const Map<String, Object> defaults = <String, Object>{
    'saveChanges': 'Save changes',
    'save': 'Save',
    'saveDraft': 'Save draft',
    'cancel': 'Cancel',
  };

  /// The text for [key]: the page value, else the EN default, else [key].
  String text(String key) {
    final Object? value = values[key] ?? defaults[key];
    return value is String ? value : key;
  }

  /// The list for [key] (tab labels and similar), or an empty list.
  List<String> list(String key) {
    final Object? value = values[key] ?? defaults[key];
    return value is List<String> ? value : const <String>[];
  }
}

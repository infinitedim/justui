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
  /// EN defaults: the `en` entry of `kitTranslations`, every key.
  /// `test/scenes/strings_drift_test.dart` keeps the two equal.
  static const Map<String, Object> defaults = <String, Object>{
    'saveChanges': 'Save changes',
    'save': 'Save',
    'saveDraft': 'Save draft',
    'cancel': 'Cancel',
    'wifi': 'Wi-Fi',
    'remember': 'Remember this device',
    'project': 'Project name',
    'badProject': 'Use lowercase letters, numbers and underscores.',
    'sendTo': 'Send to',
    'badEmail': 'Enter an email address, like team@example.com.',
    'volume': 'Volume',
    'alertVolume': 'Alert volume',
    'frequency': 'Frequency',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'uploading': 'Uploading',
    'draft': 'Draft',
    'tabs': <String>['Account', 'Billing', 'Team'],
    'saved': 'Saved',
    'savedBody': 'Project settings updated.',
    'notifSaved': 'Notification settings updated.',
    'notifications': 'Notifications',
    'notificationsBody': 'Choose what reaches your inbox.',
    'productUpdates': 'Product updates',
    'weeklyDigest': 'Weekly digest',
    'copy': 'Copy',
    'accordionQuestion': 'What is a runner?',
    'accordionAnswer': 'One preset, with every part on it.',
    'discardTitle': 'Discard changes?',
    'discard': 'Discard',
    'share': 'Share project',
    'sidebar': <String>['Overview', 'Components', 'Settings'],
    'bottomNav': <String>['Home', 'Search', 'Profile'],
    'part': 'Part',
    'folder': 'Folder',
    'month': 'October',
    'slide': 'Slide {index} of {total}',
    'slideAria': 'Go to slide {index}',
    'files': 'Files',
    'editor': 'Editor',
    'settings': 'Settings',
    'add': 'Add',
    'bold': 'Bold',
    'breadcrumb': 'Breadcrumb',
    'sidebarLabel': 'Sections',
    'bottomNavLabel': 'App navigation',
    'tabsLabel': 'Settings sections',
    'daysLabel': 'Days in October',
    'slidesLabel': 'Slides',
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

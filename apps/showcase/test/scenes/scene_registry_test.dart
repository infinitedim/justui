import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:showcase/scenes/scene_registry.dart';

/// Public part slugs from the registry (shared internals excluded).
Set<String> registrySlugs() {
  final Object? index = jsonDecode(
    File('../../registry/index.json').readAsStringSync(),
  );
  final List<Object?> components =
      (index! as Map<String, Object?>)['components']! as List<Object?>;
  return components
      .map((Object? c) => (c! as Map<String, Object?>)['name']! as String)
      .where((String name) => !name.startsWith('_'))
      .toSet();
}

void main() {
  test('scenes are keyed by real registry slugs', () {
    final Set<String> slugs = registrySlugs();
    expect(slugs, hasLength(33));
    expect(slugs.containsAll(sceneRegistry.keys), isTrue);
    expect(slugs.containsAll(reactOnlyScenes), isTrue);
    expect(sceneRegistry.keys.toSet().intersection(reactOnlyScenes), isEmpty);
  });
}

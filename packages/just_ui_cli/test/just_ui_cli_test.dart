import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:just_ui_cli/just_ui_cli.dart';
import 'package:test/test.dart';

void main() {
  late FileSystem fs;
  late List<String> logs;

  setUp(() {
    fs = MemoryFileSystem();
    logs = [];
    JustLogger.testStdoutSink = (msg) => logs.add(msg);
  });

  tearDown(() {
    JustLogger.testStdoutSink = null;
  });

  group('JustUIConfig Tests', () {
    test('Parses from YAML correctly', () {
      const yaml = '''
components_dir: custom/ui
tokens_dir: custom/tokens
registry_url: http://example.com/reg
''';
      final config = JustUIConfig.fromYaml(yaml);
      expect(config.componentsDir, equals('custom/ui'));
      expect(config.tokensDir, equals('custom/tokens'));
      expect(config.registryUrl, equals('http://example.com/reg'));
    });

    test('Falls back to defaults if parsing fails', () {
      final config = JustUIConfig.fromYaml('invalid yaml map');
      expect(config.componentsDir, equals('lib/ui'));
      expect(config.tokensDir, equals('lib/tokens'));
    });
  });

  group('PubspecEditor Tests', () {
    test('Safely adds dependency and creates backup', () {
      fs.file('pubspec.yaml').writeAsStringSync('''
name: my_project
dependencies:
  flutter:
    sdk: flutter
''');

      final editor = PubspecEditor(fs);
      editor.addDependency(
        dependencyName: 'flutter_animate',
        versionConstraint: '^1.0.0',
        pubspecPath: 'pubspec.yaml',
      );

      // Verify backup is created
      expect(fs.file('pubspec.yaml.bak').existsSync(), isTrue);

      final updated = fs.file('pubspec.yaml').readAsStringSync();
      expect(updated, contains('  flutter_animate: "^1.0.0"'));
      expect(updated, contains('dependencies:'));
    });
  });

  group('CLI Commands Tests', () {
    test('InitCommand generates config if pubspec exists', () async {
      // Missing pubspec
      await runCli(['init'], fs);
      expect(
        logs.any((l) => l.contains('Error: No pubspec.yaml found')),
        isTrue,
      );
      expect(fs.file('justui.config.yaml').existsSync(), isFalse);

      // Present pubspec
      fs.file('pubspec.yaml').writeAsStringSync('name: test');
      logs.clear();

      await runCli(['init'], fs);
      expect(
        logs.any((l) => l.contains('success: JustUI initialized successfully')),
        isTrue,
      );
      expect(fs.file('justui.config.yaml').existsSync(), isTrue);
    });

    test('ListCommand prints categorized registry index', () async {
      fs.directory('mock_registry').createSync();
      final indexFile = fs.file('mock_registry/index.json');
      indexFile.writeAsStringSync(
        jsonEncode({
          'version': '1',
          'components': [
            {
              'name': 'button',
              'version': '0.1.0',
              'description': 'A nice button',
              'category': 'primitives',
              'files': [],
              'registryDependencies': [],
              'pubDependencies': {},
            },
          ],
        }),
      );

      // Setup local config pointing to mock registry
      fs.file('pubspec.yaml').writeAsStringSync('name: test');
      fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');

      await runCli(['list'], fs);
      expect(logs.any((l) => l.contains('Available components')), isTrue);
      expect(logs.any((l) => l.contains('Primitives:')), isTrue);
      expect(logs.any((l) => l.contains('button')), isTrue);
    });

    test(
      'AddCommand downloads files and resolves dependencies recursively',
      () async {
        // Setup mock registry files
        fs
            .file('pubspec.yaml')
            .writeAsStringSync(
              'name: test\ndependencies:\n  flutter:\n    sdk: flutter',
            );
        fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');

        // Registry index defining dependency (button depends on spacing token)
        fs
            .file('mock_registry/index.json')
            .writeAsStringSync(
              jsonEncode({
                'version': '1',
                'components': [
                  {
                    'name': 'button',
                    'version': '0.1.0',
                    'description': 'Button component',
                    'category': 'primitives',
                    'registryDependencies': ['spacing'],
                    'pubDependencies': {'flutter_animate': '^1.0.0'},
                    'files': [
                      {
                        'name': 'just_button.dart',
                        'path': 'components/button/just_button.dart',
                        'checksum':
                            'sha256:${sha256.convert(utf8.encode('button_code')).toString()}',
                      },
                    ],
                  },
                  {
                    'name': 'spacing',
                    'version': '0.1.0',
                    'description': 'Spacing tokens',
                    'category': 'tokens',
                    'registryDependencies': [],
                    'pubDependencies': {},
                    'files': [
                      {
                        'name': 'spacing.dart',
                        'path': 'tokens/spacing.dart',
                        'checksum':
                            'sha256:${sha256.convert(utf8.encode('spacing_code')).toString()}',
                      },
                    ],
                  },
                ],
              }),
            );

        fs.file('mock_registry/components/button/just_button.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('button_code');

        fs.file('mock_registry/tokens/spacing.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('spacing_code');

        await runCli(['add', 'button'], fs);

        // Verify files are copied to correct locations
        expect(fs.file('lib/ui/button/just_button.dart').existsSync(), isTrue);
        expect(
          fs.file('lib/ui/button/just_button.dart').readAsStringSync(),
          equals('button_code'),
        );

        // Verify registry dependency is copied to tokensDir
        expect(fs.file('lib/tokens/spacing.dart').existsSync(), isTrue);
        expect(
          fs.file('lib/tokens/spacing.dart').readAsStringSync(),
          equals('spacing_code'),
        );

        // Verify pub dependency is added
        expect(
          fs.file('pubspec.yaml').readAsStringSync(),
          contains('flutter_animate: "^1.0.0"'),
        );
      },
    );

    test(
      'AddCommand handles circular dependencies gracefully using visited set',
      () async {
        fs.file('pubspec.yaml').writeAsStringSync('name: test');
        fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');

        // A depends on B, B depends on A
        fs
            .file('mock_registry/index.json')
            .writeAsStringSync(
              jsonEncode({
                'version': '1',
                'components': [
                  {
                    'name': 'compA',
                    'version': '0.1.0',
                    'description': 'A',
                    'category': 'primitives',
                    'registryDependencies': ['compB'],
                    'pubDependencies': {},
                    'files': [
                      {
                        'name': 'a.dart',
                        'path': 'components/a.dart',
                        'checksum':
                            'sha256:${sha256.convert(utf8.encode('a')).toString()}',
                      },
                    ],
                  },
                  {
                    'name': 'compB',
                    'version': '0.1.0',
                    'description': 'B',
                    'category': 'primitives',
                    'registryDependencies': ['compA'],
                    'pubDependencies': {},
                    'files': [
                      {
                        'name': 'b.dart',
                        'path': 'components/b.dart',
                        'checksum':
                            'sha256:${sha256.convert(utf8.encode('b')).toString()}',
                      },
                    ],
                  },
                ],
              }),
            );

        fs.file('mock_registry/components/a.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('a');

        fs.file('mock_registry/components/b.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('b');

        // Run and verify it finishes successfully (not looping infinitely)
        await runCli(['add', 'compA'], fs);

        expect(fs.file('lib/ui/compA/a.dart').existsSync(), isTrue);
        expect(fs.file('lib/ui/compB/b.dart').existsSync(), isTrue);
      },
    );

    test(
      'DiffCommand detects changes and prints line-by-line diff on verbose mode',
      () async {
        fs.file('pubspec.yaml').writeAsStringSync('name: test');
        fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');

        final componentHash = sha256
            .convert(utf8.encode('original'))
            .toString();

        fs
            .file('mock_registry/index.json')
            .writeAsStringSync(
              jsonEncode({
                'version': '1',
                'components': [
                  {
                    'name': 'button',
                    'version': '0.1.0',
                    'description': 'Button',
                    'category': 'primitives',
                    'registryDependencies': [],
                    'pubDependencies': {},
                    'files': [
                      {
                        'name': 'just_button.dart',
                        'path': 'components/button/just_button.dart',
                        'checksum': 'sha256:$componentHash',
                      },
                    ],
                  },
                ],
              }),
            );

        fs.file('mock_registry/components/button/just_button.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('original');

        // Case 1: Matching checksum
        fs.file('lib/ui/button/just_button.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('original');

        logs.clear();
        await runCli(['diff', 'button'], fs);
        expect(
          logs.any((l) => l.contains('success: just_button.dart: Up to date')),
          isTrue,
        );

        // Case 2: Modified checksum (non-verbose)
        fs.file('lib/ui/button/just_button.dart').writeAsStringSync('modified');
        logs.clear();
        await runCli(['diff', 'button'], fs);
        expect(
          logs.any(
            (l) => l.contains('warning: just_button.dart: Modified locally'),
          ),
          isTrue,
        );
        expect(logs.any((l) => l.contains('Line-by-line diff')), isFalse);

        // Case 3: Modified checksum (verbose)
        logs.clear();
        await runCli(['diff', 'button', '-v'], fs);
        expect(
          logs.any((l) => l.contains('Line-by-line diff for just_button.dart')),
          isTrue,
        );
        expect(logs.any((l) => l.contains('Local:    modified')), isTrue);
        expect(logs.any((l) => l.contains('Registry: original')), isTrue);
      },
    );
  });
}

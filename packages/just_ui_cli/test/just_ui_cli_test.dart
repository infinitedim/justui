import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:just_ui_cli/just_ui_cli.dart';
import 'package:just_ui_cli/src/utils/import_rewriter.dart';
import 'package:just_ui_cli/src/utils/diff_formatter.dart';
import 'package:test/test.dart';

void main() {
  late FileSystem fs;
  late List<String> logs;

  setUp(() {
    fs = MemoryFileSystem();
    logs = [];
    JustLogger.testStdoutSink = (msg) => logs.add(msg);
    JustPrompt.testInputReader = () => '';
  });

  tearDown(() {
    JustLogger.testStdoutSink = null;
    JustPrompt.testInputReader = null;
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
        logs.any((l) => l.contains('JustUI configuration initialized')),
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

        fs.directory('mock_registry').createSync(recursive: true);

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
          ImportRewriter.stripMetadata(fs.file('lib/ui/button/just_button.dart').readAsStringSync()).trim(),
          equals('button_code'),
        );

        // Verify registry dependency is copied to tokensDir
        expect(fs.file('lib/tokens/spacing.dart').existsSync(), isTrue);
        expect(
          ImportRewriter.stripMetadata(fs.file('lib/tokens/spacing.dart').readAsStringSync()).trim(),
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

        fs.directory('mock_registry').createSync(recursive: true);

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

        fs.directory('mock_registry').createSync(recursive: true);

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
          logs.any((l) => l.contains('just_button.dart: Up to date')),
          isTrue,
        );

        // Case 2: Modified checksum (non-verbose)
        fs.file('lib/ui/button/just_button.dart').writeAsStringSync('modified');
        logs.clear();
        await runCli(['diff', 'button'], fs);
        expect(
          logs.any((l) => l.contains('just_button.dart: Modified locally')),
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

    test(
      'AddCommand fails if downloaded file checksum mismatches expected hash',
      () async {
        fs.file('pubspec.yaml').writeAsStringSync('name: test');
        fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');

        fs.directory('mock_registry').createSync(recursive: true);

        fs
            .file('mock_registry/index.json')
            .writeAsStringSync(
              jsonEncode({
                'version': '1',
                'components': [
                  {
                    'name': 'corrupted',
                    'version': '0.1.0',
                    'description': 'Corrupted component',
                    'category': 'primitives',
                    'registryDependencies': [],
                    'pubDependencies': {},
                    'files': [
                      {
                        'name': 'corrupted.dart',
                        'path': 'components/corrupted.dart',
                        'checksum': 'sha256:mismatchinghash1234567890',
                      },
                    ],
                  },
                ],
              }),
            );

        fs.file('mock_registry/components/corrupted.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('some file content');

        logs.clear();
        await runCli(['add', 'corrupted'], fs);

        expect(
          logs.any((l) => l.contains('Error: Failed to add component')),
          isTrue,
        );
        expect(logs.any((l) => l.contains('Checksum mismatch')), isTrue);
        expect(
          fs.file('lib/ui/corrupted/corrupted.dart').existsSync(),
          isFalse,
        );
      },
    );

    test(
      'DiffCommand normalizes CRLF and LF to avoid cross-platform mismatches',
      () async {
        fs.file('pubspec.yaml').writeAsStringSync('name: test');
        fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');

        fs.directory('mock_registry').createSync(recursive: true);

        // Hash is calculated from 'line1\nline2' (LF)
        final lfHash = sha256.convert(utf8.encode('line1\nline2')).toString();

        fs
            .file('mock_registry/index.json')
            .writeAsStringSync(
              jsonEncode({
                'version': '1',
                'components': [
                  {
                    'name': 'lineending',
                    'version': '0.1.0',
                    'description': 'Line Ending Check',
                    'category': 'primitives',
                    'registryDependencies': [],
                    'pubDependencies': {},
                    'files': [
                      {
                        'name': 'le.dart',
                        'path': 'components/le.dart',
                        'checksum': 'sha256:$lfHash',
                      },
                    ],
                  },
                ],
              }),
            );

        fs.file('mock_registry/components/le.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('line1\nline2');

        // Local file is saved with CRLF ('line1\r\nline2')
        fs.file('lib/ui/lineending/le.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('line1\r\nline2');

        logs.clear();
        await runCli(['diff', 'lineending'], fs);

        // Should normalize CRLF to LF, match the hashes, and say "Up to date"
        expect(logs.any((l) => l.contains('le.dart: Up to date')), isTrue);
      },
    );
  });

  group('Interactive CLI & Scaffolding Tests', () {
    test('JustPrompt confirm and ask work with mock input', () {
      int idx = 0;
      final inputs = ['y', 'no', 'custom_value'];
      JustPrompt.testInputReader = () => inputs[idx++];

      expect(JustPrompt.confirm('Message'), isTrue);
      expect(JustPrompt.confirm('Message'), isFalse);
      expect(
        JustPrompt.ask('Message', defaultValue: 'default'),
        equals('custom_value'),
      );
    });

    test('JustPrompt selectMultiple works with indices and all', () {
      int idx = 0;
      final inputs = ['1, 3', 'all'];
      JustPrompt.testInputReader = () => inputs[idx++];

      final options = ['opt1', 'opt2', 'opt3', 'opt4'];
      expect(JustPrompt.selectMultiple('Message', options), equals([0, 2]));
      expect(
        JustPrompt.selectMultiple('Message', options),
        equals([0, 1, 2, 3]),
      );
    });

    test(
      'InitCommand wizard custom inputs generate seeded theme class',
      () async {
        fs.file('pubspec.yaml').writeAsStringSync('name: test');

        int idx = 0;
        final inputs = ['default', 'src/ui', 'src/tokens', '#ff00ff'];
        JustPrompt.testInputReader = () => inputs[idx++];

        await runCli(['init'], fs);

        expect(fs.file('justui.config.yaml').existsSync(), isTrue);
        final configContent = fs.file('justui.config.yaml').readAsStringSync();
        expect(configContent, contains('components_dir: src/ui'));
        expect(configContent, contains('tokens_dir: src/tokens'));

        expect(fs.file('lib/theme/just_theme.dart').existsSync(), isTrue);
        final themeContent = fs
            .file('lib/theme/just_theme.dart')
            .readAsStringSync();
        expect(themeContent, contains('const Color(0xFFFF00FF)'));
      },
    );

    test('AddCommand interactive selection when no arguments', () async {
      fs.file('pubspec.yaml').writeAsStringSync('name: test');
      fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');
      fs.directory('mock_registry').createSync(recursive: true);
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
                  'registryDependencies': [],
                  'pubDependencies': {},
                  'files': [
                    {
                      'name': 'just_button.dart',
                      'path': 'components/button/just_button.dart',
                      'checksum':
                          'sha256:${sha256.convert(utf8.encode('button_code')).toString()}',
                    },
                  ],
                },
              ],
            }),
          );
      fs.file('mock_registry/components/button/just_button.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('button_code');

      // Select first component (index 1)
      int idx = 0;
      final inputs = ['1'];
      JustPrompt.testInputReader = () => inputs[idx++];

      await runCli(['add'], fs);

      expect(fs.file('lib/ui/button/just_button.dart').existsSync(), isTrue);
      expect(
        ImportRewriter.stripMetadata(fs.file('lib/ui/button/just_button.dart').readAsStringSync()).trim(),
        equals('button_code'),
      );
    });

    test(
      'AddCommand Overwrite Guard prompts when local content differs',
      () async {
        fs.file('pubspec.yaml').writeAsStringSync('name: test');
        fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');
        fs.directory('mock_registry').createSync(recursive: true);

        final expectedHash = sha256
            .convert(utf8.encode('remote_code'))
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
                        'checksum': 'sha256:$expectedHash',
                      },
                    ],
                  },
                ],
              }),
            );
        fs.file('mock_registry/components/button/just_button.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('remote_code');

        // Local file exists and differs
        final localFile = fs.file('lib/ui/button/just_button.dart')
          ..createSync(recursive: true)
          ..writeAsStringSync('local_code');

        // First run: choose 's' (skip)
        int idx = 0;
        var inputs = ['s'];
        JustPrompt.testInputReader = () => inputs[idx++];

        await runCli(['add', 'button'], fs);
        expect(localFile.readAsStringSync(), equals('local_code'));

        // Second run: choose 'o' (overwrite)
        idx = 0;
        inputs = ['o'];
        JustPrompt.testInputReader = () => inputs[idx++];

        await runCli(['add', 'button'], fs);
        expect(
          ImportRewriter.stripMetadata(localFile.readAsStringSync()).trim(),
          equals('remote_code'),
        );
      },
    );

    test('UpdateCommand updates outdated components', () async {
      fs.file('pubspec.yaml').writeAsStringSync('name: test');
      fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');
      fs.directory('mock_registry').createSync(recursive: true);

      final remoteHash = sha256.convert(utf8.encode('new_code')).toString();
      fs
          .file('mock_registry/index.json')
          .writeAsStringSync(
            jsonEncode({
              'version': '1',
              'components': [
                {
                  'name': 'button',
                  'version': '0.2.0',
                  'description': 'Button',
                  'category': 'primitives',
                  'registryDependencies': [],
                  'pubDependencies': {},
                  'files': [
                    {
                      'name': 'just_button.dart',
                      'path': 'components/button/just_button.dart',
                      'checksum': 'sha256:$remoteHash',
                    },
                  ],
                },
              ],
            }),
          );
      fs.file('mock_registry/components/button/just_button.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('new_code');

      // Locally installed but outdated
      final localFile = fs.file('lib/ui/button/just_button.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('old_code');

      // Update command: select '1' (button) and then 'o' (overwrite guard)
      int idx = 0;
      final inputs = ['1', 'o'];
      JustPrompt.testInputReader = () => inputs[idx++];

      await runCli(['update'], fs);

      expect(
        ImportRewriter.stripMetadata(localFile.readAsStringSync()).trim(),
        equals('new_code'),
      );
    });

    test('CreateCommand scaffolds custom component 4-file bundle', () async {
      fs.file('pubspec.yaml').writeAsStringSync('name: test');
      fs.file('justui.config.yaml').writeAsStringSync('''
components_dir: lib/ui
tokens_dir: lib/tokens
registry_url: mock_registry
''');

      await runCli(['create', 'fancy_card'], fs);

      final componentDir = 'lib/ui/fancy_card';
      expect(fs.file('$componentDir/fancy_card.dart').existsSync(), isTrue);
      expect(
        fs.file('$componentDir/fancy_card_style.dart').existsSync(),
        isTrue,
      );
      expect(
        fs.file('$componentDir/fancy_card_variants.dart').existsSync(),
        isTrue,
      );
      expect(
        fs.file('$componentDir/fancy_card_theme.dart').existsSync(),
        isTrue,
      );

      final widgetContent = fs
          .file('$componentDir/fancy_card.dart')
          .readAsStringSync();
      expect(
        widgetContent,
        contains('class FancyCard extends StatelessWidget'),
      );
      expect(widgetContent, contains('const FancyCard({'));
      expect(widgetContent, contains('this.variant = .default_'));

      final themeContent = fs
          .file('$componentDir/fancy_card_theme.dart')
          .readAsStringSync();
      expect(
        themeContent,
        contains('class FancyCardTheme extends ThemeExtension<FancyCardTheme>'),
      );
    });
  });

  group('ImportRewriter & Diff/Selective Apply Tests', () {
    test('ImportRewriter correctly rewrites relative imports and handles theme special case', () {
      final mockIndex = RegistryIndex(
        version: '1',
        components: [
          RegistryComponent(
            name: 'button',
            version: '0.1.0',
            description: '',
            category: 'primitives',
            registryDependencies: ['_shared_pressable'],
            pubDependencies: {},
            files: [
              RegistryFile(
                name: 'just_button.dart',
                path: 'components/button/just_button.dart',
                checksum: '',
              ),
            ],
          ),
          RegistryComponent(
            name: '_shared_pressable',
            version: '0.1.0',
            description: '',
            category: 'internal',
            registryDependencies: [],
            pubDependencies: {},
            files: [
              RegistryFile(
                name: 'just_pressable.dart',
                path: 'components/shared/just_pressable.dart',
                checksum: '',
              ),
            ],
          ),
        ],
      );

      final originalContent = '''
import 'package:flutter/widgets.dart';
import '../../theme/theme_provider.dart';
import '../shared/just_pressable.dart';
''';

      final rewritten = ImportRewriter.rewrite(
        content: originalContent,
        sourceRegistryPath: 'components/button/just_button.dart',
        currentComponentName: 'button',
        registryIndex: mockIndex,
        componentsDir: 'lib/ui',
        tokensDir: 'lib/tokens',
        fileSystem: fs,
      );

      expect(rewritten, contains("import 'package:just_ui_core/just_ui_core.dart';"));
      expect(rewritten, contains("import '../_shared_pressable/just_pressable.dart';"));
    });

    test('ImportRewriter metadata parse, strip, and inject functions work as expected', () {
      const code = 'void main() {}';
      final injected = ImportRewriter.injectMetadata(code, 'reg123', 'loc456');
      expect(injected, contains('// justui-meta: registry=reg123 local=loc456'));

      final meta = ImportRewriter.parseMetadata(injected)!;
      expect(meta.registryHash, equals('reg123'));
      expect(meta.localHash, equals('loc456'));

      final stripped = ImportRewriter.stripMetadata(injected);
      expect(stripped.trim(), equals(code));
    });

    test('DiffCommand supports unified diff rendering', () {
      const local = 'line 1\nline 2\nline 3\n';
      const remote = 'line 1\nline 2 modified\nline 3\n';
      final diffLines = DiffFormatter.calculateDiff(local, remote);
      
      expect(diffLines.any((l) => l.type == '-'), isTrue);
      expect(diffLines.any((l) => l.type == '+'), isTrue);
    });
  });
}

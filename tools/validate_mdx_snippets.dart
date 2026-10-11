// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart' as p;

const Set<String> knownPrefixesOrFoundations = {
  'JustUI',
  'JustTheme',
  'JustColor',
  'JustMotion',
  'JustRadius',
  'JustShadow',
  'JustSpacing',
  'JustTypo',
  'JustFluidTypo',
  'JustBreakpoints',
  'JustCurves',
  'JustDuration',
  'JustGap',
  'JustOverlay',
  'JustRangeValues',
  'JustCalendarView',
  'JustFormInput',
  'JustScroll',
  'JustTab',
  'JustDate',
};

Set<String> collectDeclaredSymbols(String dirPath) {
  final Set<String> symbols = {};
  final Directory dir = Directory(dirPath);
  if (!dir.existsSync()) {
    return symbols;
  }

  final RegExp symbolRegex = RegExp(
    r'\b(?:(?:abstract|base|final|interface|sealed|mixin)\s+)*(?:class|enum|mixin|extension(?:\s+type)?|typedef)\s+(?:const\s+)?(Just[A-Za-z0-9_]+)\b',
  );

  for (final FileSystemEntity entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final String content = entity.readAsStringSync();
      for (final RegExpMatch match in symbolRegex.allMatches(content)) {
        final String? name = match.group(1);
        if (name != null) {
          symbols.add(name);
        }
      }
    }
  }
  return symbols;
}

List<File> findMdxFiles(Directory dir) {
  final List<File> files = [];
  if (!dir.existsSync()) {
    return files;
  }

  for (final FileSystemEntity entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.mdx')) {
      files.add(entity);
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

class DartSnippet {
  final String filePath;
  final int startLine;
  final String code;

  DartSnippet({
    required this.filePath,
    required this.startLine,
    required this.code,
  });
}

List<DartSnippet> extractSnippets(File file) {
  final List<DartSnippet> snippets = [];
  final List<String> lines = file.readAsLinesSync();

  bool inSnippet = false;
  int startLine = 0;
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    final String trimmed = line.trim();

    if (!inSnippet) {
      if (trimmed == '```dart' ||
          trimmed.startsWith('```dart ') ||
          trimmed.endsWith('```dart')) {
        inSnippet = true;
        startLine = i + 1;
        buffer.clear();
      }
    } else {
      if (trimmed == '```' || trimmed.endsWith('```')) {
        inSnippet = false;
        snippets.add(
          DartSnippet(
            filePath: file.path,
            startLine: startLine,
            code: buffer.toString(),
          ),
        );
        buffer.clear();
      } else {
        buffer.writeln(line);
      }
    }
  }

  return snippets;
}

bool checkBalancedBrackets(String code) {
  final List<String> stack = [];
  bool inSingleLineComment = false;
  bool inMultiLineComment = false;
  bool inSingleQuote = false;
  bool inDoubleQuote = false;
  bool inTripleSingleQuote = false;
  bool inTripleDoubleQuote = false;

  for (int i = 0; i < code.length; i++) {
    final String char = code[i];
    final String nextChar = (i + 1 < code.length) ? code[i + 1] : '';
    final String prevChar = (i > 0) ? code[i - 1] : '';

    if (inSingleLineComment) {
      if (char == '\n') inSingleLineComment = false;
      continue;
    }

    if (inMultiLineComment) {
      if (char == '*' && nextChar == '/') {
        inMultiLineComment = false;
        i++;
      }
      continue;
    }

    if (inTripleSingleQuote) {
      if (char == "'" &&
          nextChar == "'" &&
          i + 2 < code.length &&
          code[i + 2] == "'") {
        inTripleSingleQuote = false;
        i += 2;
      }
      continue;
    }

    if (inTripleDoubleQuote) {
      if (char == '"' &&
          nextChar == '"' &&
          i + 2 < code.length &&
          code[i + 2] == '"') {
        inTripleDoubleQuote = false;
        i += 2;
      }
      continue;
    }

    if (inSingleQuote) {
      if (char == "'" && prevChar != r'\') inSingleQuote = false;
      continue;
    }

    if (inDoubleQuote) {
      if (char == '"' && prevChar != r'\') inDoubleQuote = false;
      continue;
    }

    // Check for comment starts
    if (char == '/' && nextChar == '/') {
      inSingleLineComment = true;
      i++;
      continue;
    }
    if (char == '/' && nextChar == '*') {
      inMultiLineComment = true;
      i++;
      continue;
    }

    // Check for string starts
    if (char == "'" &&
        nextChar == "'" &&
        i + 2 < code.length &&
        code[i + 2] == "'") {
      inTripleSingleQuote = true;
      i += 2;
      continue;
    }
    if (char == '"' &&
        nextChar == '"' &&
        i + 2 < code.length &&
        code[i + 2] == '"') {
      inTripleDoubleQuote = true;
      i += 2;
      continue;
    }
    if (char == "'") {
      inSingleQuote = true;
      continue;
    }
    if (char == '"') {
      inDoubleQuote = true;
      continue;
    }

    // Brackets
    if (char == '(' || char == '[' || char == '{') {
      stack.add(char);
    } else if (char == ')' || char == ']' || char == '}') {
      if (stack.isEmpty) return false;
      final String last = stack.removeLast();
      if (char == ')' && last != '(') return false;
      if (char == ']' && last != '[') return false;
      if (char == '}' && last != '{') return false;
    }
  }

  return stack.isEmpty;
}

void main(List<String> args) {
  final String scriptPath = File(Platform.script.toFilePath()).absolute
      .resolveSymbolicLinksSync();
  final String projectRoot = p.dirname(p.dirname(scriptPath));

  final String docsContentDir = p.join(
    projectRoot,
    'apps',
    'docs',
    'content',
    'docs',
  );
  final String coreDir = p.join(projectRoot, 'packages', 'core', 'lib');
  final String tokensDir = p.join(projectRoot, 'packages', 'tokens', 'lib');

  final Set<String> knownSymbols = {
    ...collectDeclaredSymbols(coreDir),
    ...collectDeclaredSymbols(tokensDir),
  };

  final List<File> mdxFiles = findMdxFiles(Directory(docsContentDir));
  if (mdxFiles.isEmpty) {
    stderr.writeln('No MDX files found in $docsContentDir');
    exit(1);
  }

  final RegExp justSymbolRegex = RegExp(r'\bJust[A-Z][a-zA-Z0-9]+\b');
  int totalSnippets = 0;
  int errorCount = 0;

  for (final File mdxFile in mdxFiles) {
    final String relPath = p.relative(mdxFile.path, from: projectRoot);
    final List<DartSnippet> snippets = extractSnippets(mdxFile);

    for (final DartSnippet snippet in snippets) {
      totalSnippets++;

      // 1. Check for banned package imports
      if (snippet.code.contains('package:just_ui_core')) {
        stderr.writeln(
          'Error in $relPath:${snippet.startLine}: forbidden import of package:just_ui_core',
        );
        errorCount++;
      }
      if (snippet.code.contains('package:just_ui_tokens')) {
        stderr.writeln(
          'Error in $relPath:${snippet.startLine}: forbidden import of package:just_ui_tokens',
        );
        errorCount++;
      }

      // 2. Check balanced brackets/syntax
      if (!checkBalancedBrackets(snippet.code)) {
        stderr.writeln(
          'Warning in $relPath:${snippet.startLine}: unbalanced brackets or unclosed quotes',
        );
      }

      // 3. Verify Just* symbols against core/tokens declarations
      for (final RegExpMatch match in justSymbolRegex.allMatches(
        snippet.code,
      )) {
        final String symbol = match.group(0)!;
        final bool isPrefixMatch = knownPrefixOrFoundation(symbol);
        final bool isKnown = knownSymbols.contains(symbol) || isPrefixMatch;

        if (!isKnown) {
          stderr.writeln(
            'Error in $relPath:${snippet.startLine}: unknown symbol "$symbol" not found in packages/core or packages/tokens',
          );
          errorCount++;
        }
      }
    }
  }

  if (errorCount > 0) {
    stderr.writeln(
      'MDX Dart snippet validation failed with $errorCount errors across $totalSnippets snippets.',
    );
    exit(1);
  }

  print(
    'Successfully validated $totalSnippets Dart snippets across ${mdxFiles.length} MDX files.',
  );
  exit(0);
}

bool knownPrefixOrFoundation(String symbol) {
  for (final String prefix in knownPrefixesOrFoundations) {
    if (symbol.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}

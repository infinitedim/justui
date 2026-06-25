import 'dart:io' as io;

/// A utility class for console prompting.
class JustPrompt {
  /// Custom input reader for test suites.
  static String? Function()? testInputReader;

  /// Reads a line of input from stdin or test mock.
  static String? _readLine() {
    if (testInputReader != null) {
      return testInputReader!();
    }
    return io.stdin.readLineSync();
  }

  /// Prompts for a yes/no confirmation.
  static bool confirm(String message, {bool defaultValue = false}) {
    final suffix = defaultValue ? '[Y/n]' : '[y/N]';
    io.stdout.write('$message $suffix: ');
    final input = _readLine()?.trim().toLowerCase() ?? '';
    if (input.isEmpty) return defaultValue;
    return input == 'y' || input == 'yes';
  }

  /// Prompts the user to select indices from a list.
  ///
  /// Returns a list of 0-based selected indices.
  static List<int> selectMultiple(String message, List<String> options) {
    for (int i = 0; i < options.length; i++) {
      io.stdout.writeln('  [${i + 1}] ${options[i]}');
    }
    io.stdout.write('$message (e.g. 1, 3 or "all"): ');
    final input = _readLine()?.trim().toLowerCase() ?? '';

    if (input == 'all') {
      return List<int>.generate(options.length, (index) => index);
    }

    final selected = <int>[];
    final parts = input.split(',');
    for (final part in parts) {
      final parsed = int.tryParse(part.trim());
      if (parsed != null && parsed >= 1 && parsed <= options.length) {
        selected.add(parsed - 1);
      }
    }
    return selected;
  }

  /// Prompts the user to select a single item from a numbered list.
  ///
  /// Returns the 0-based index of the chosen option.
  /// Falls back to [defaultIndex] on empty input or invalid selection.
  static int selectOne(
    String message,
    List<String> options, {
    int defaultIndex = 0,
  }) {
    for (int i = 0; i < options.length; i++) {
      final marker = i == defaultIndex ? '*' : ' ';
      io.stdout.writeln('  [$marker${i + 1}] ${options[i]}');
    }
    io.stdout.write('$message (default: ${defaultIndex + 1}): ');
    final input = _readLine()?.trim() ?? '';
    if (input.isEmpty) return defaultIndex;
    final parsed = int.tryParse(input);
    if (parsed != null && parsed >= 1 && parsed <= options.length) {
      return parsed - 1;
    }
    return defaultIndex;
  }

  /// Prompts for a string input.
  static String ask(String message, {required String defaultValue}) {
    io.stdout.write('$message [$defaultValue]: ');
    final input = _readLine()?.trim() ?? '';
    return input.isEmpty ? defaultValue : input;
  }
}

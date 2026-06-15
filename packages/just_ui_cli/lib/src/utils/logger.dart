/// A lightweight terminal logger that formats console output with ANSI escape colors.
abstract final class JustLogger {
  /// Custom output sink for testing and capture purposes.
  static void Function(String)? testStdoutSink;

  /// Logs a green success message with a checkmark.
  static void success(String message) => _print('\x1B[32m✓ $message\x1B[0m');

  /// Logs a red error message with a cross icon.
  static void error(String message) =>
      _print('\x1B[31m✗ Error: $message\x1B[0m');

  /// Logs a yellow warning message.
  static void warning(String message) =>
      _print('\x1B[33m⚠ Warning: $message\x1B[0m');

  /// Logs a cyan informational message.
  static void info(String message) => _print('\x1B[36mℹ $message\x1B[0m');

  /// Logs a plain unformatted line to the console.
  static void stdout(String message) => _print(message);

  static void _print(String formatted) {
    if (testStdoutSink != null) {
      testStdoutSink!(formatted);
    } else {
      print(formatted);
    }
  }
}

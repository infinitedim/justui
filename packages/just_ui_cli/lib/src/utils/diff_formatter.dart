import 'dart:math';
import 'logger.dart';

/// Represents a single line in a calculated diff.
class DiffLine {
  /// Type of diff: ' ' (unchanged), '+' (added in remote), '-' (removed in local).
  final String type;

  /// The text content of the line.
  final String text;

  /// The line number in the local file (1-indexed), or 0 if not present.
  final int localLineNum;

  /// The line number in the remote file (1-indexed), or 0 if not present.
  final int remoteLineNum;

  /// Creates a [DiffLine].
  DiffLine(this.type, this.text, this.localLineNum, this.remoteLineNum);
}

/// A utility class for calculating and formatting visual diffs between files.
class DiffFormatter {
  /// Computes the diff between [local] and [remote] using an LCS algorithm.
  static List<DiffLine> calculateDiff(String local, String remote) {
    final localNormalized = local.replaceAll('\r\n', '\n');
    final remoteNormalized = remote.replaceAll('\r\n', '\n');

    final localLines = localNormalized.split('\n');
    final remoteLines = remoteNormalized.split('\n');

    final n = localLines.length;
    final m = remoteLines.length;

    // dp[i][j] stores length of LCS of localLines[0..i-1] and remoteLines[0..j-1]
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        if (localLines[i - 1] == remoteLines[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    final List<DiffLine> reversedDiff = [];
    int i = n;
    int j = m;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && localLines[i - 1] == remoteLines[j - 1]) {
        reversedDiff.add(DiffLine(' ', localLines[i - 1], i, j));
        i--;
        j--;
      } else if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
        reversedDiff.add(DiffLine('+', remoteLines[j - 1], 0, j));
        j--;
      } else {
        reversedDiff.add(DiffLine('-', localLines[i - 1], i, 0));
        i--;
      }
    }

    return reversedDiff.reversed.toList();
  }

  /// Formats and prints a unified diff inside a bordered panel.
  static void printUnifiedDiff(
    String fileName,
    String local,
    String remote, {
    int contextCount = 3,
  }) {
    final diffLines = calculateDiff(local, remote);

    // Find all changed line indices
    final List<int> changeIndices = [];
    for (int idx = 0; idx < diffLines.length; idx++) {
      if (diffLines[idx].type != ' ') {
        changeIndices.add(idx);
      }
    }

    if (changeIndices.isEmpty) {
      JustLogger.success('  $fileName: No changes detected.');
      return;
    }

    // Group changed indices into hunks
    final List<List<int>> groups = [];
    List<int>? currentGroup;

    for (final idx in changeIndices) {
      if (currentGroup == null) {
        currentGroup = [idx];
        groups.add(currentGroup);
      } else {
        final lastIdx = currentGroup.last;
        // Merge if changes are within 2 * contextCount + 1 lines
        if (idx - lastIdx <= (2 * contextCount) + 1) {
          currentGroup.add(idx);
        } else {
          currentGroup = [idx];
          groups.add(currentGroup);
        }
      }
    }

    // Print header border
    final borderLength = max(40, fileName.length + 8);
    final headerBorder =
        '┌─ $fileName ${"─" * (borderLength - fileName.length - 4)}';
    JustLogger.stdout(headerBorder);

    for (final group in groups) {
      final startIdx = max(0, group.first - contextCount);
      final endIdx = min(diffLines.length - 1, group.last + contextCount);

      // Find local start line number and count
      int localStart = 0;
      int localCount = 0;
      for (int k = startIdx; k <= endIdx; k++) {
        final line = diffLines[k];
        if (line.localLineNum > 0) {
          if (localStart == 0) {
            localStart = line.localLineNum;
          }
          localCount++;
        }
      }

      // Find remote start line number and count
      int remoteStart = 0;
      int remoteCount = 0;
      for (int k = startIdx; k <= endIdx; k++) {
        final line = diffLines[k];
        if (line.remoteLineNum > 0) {
          if (remoteStart == 0) {
            remoteStart = line.remoteLineNum;
          }
          remoteCount++;
        }
      }

      // Print hunk header
      final hunkHeader =
          '│ @@ -$localStart,$localCount +$remoteStart,$remoteCount @@';
      JustLogger.stdout('\x1B[36m$hunkHeader\x1B[0m');

      // Print hunk lines
      for (int k = startIdx; k <= endIdx; k++) {
        final line = diffLines[k];
        if (line.type == '+') {
          JustLogger.stdout('\x1B[32m│ +  ${line.text}\x1B[0m');
        } else if (line.type == '-') {
          JustLogger.stdout('\x1B[31m│ -  ${line.text}\x1B[0m');
        } else {
          JustLogger.stdout('│    ${line.text}');
        }
      }
    }

    // Print footer border
    final footerBorder = '└${"─" * borderLength}';
    JustLogger.stdout(footerBorder);
  }
}

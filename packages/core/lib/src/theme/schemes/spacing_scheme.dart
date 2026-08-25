import 'package:just_ui_tokens/just_ui_tokens.dart';

/// Defines the spacing values configuration.
abstract final class JustSpacingScheme {
  /// Base constructor.
  const JustSpacingScheme();

  /// Extra extra small spacing.
  double get xxs;

  /// Extra small spacing.
  double get xs;

  /// Small spacing.
  double get sm;

  /// Medium spacing.
  double get md;

  /// Large spacing.
  double get lg;

  /// Extra large spacing.
  double get xl;

  /// Double extra large spacing.
  double get xxl;

  /// Triple extra large spacing.
  double get xxxl;

  /// Huge spacing.
  double get huge;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustSpacingScheme &&
        other.xxs == xxs &&
        other.xs == xs &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.xxl == xxl &&
        other.xxxl == xxxl &&
        other.huge == huge;
  }

  @override
  int get hashCode {
    return Object.hashAll([xxs, xs, sm, md, lg, xl, xxl, xxxl, huge]);
  }

  /// Resolves the spacing scheme for a given screen width. Defaults to returning itself.
  JustSpacingScheme resolve(double width) => this;
}

final class DefaultSpacingScheme extends JustSpacingScheme {
  const DefaultSpacingScheme();

  @override
  double get xxs => JustSpacing.xxs;
  @override
  double get xs => JustSpacing.xs;
  @override
  double get sm => JustSpacing.sm;
  @override
  double get md => JustSpacing.md;
  @override
  double get lg => JustSpacing.lg;
  @override
  double get xl => JustSpacing.xl;
  @override
  double get xxl => JustSpacing.xxl;
  @override
  double get xxxl => JustSpacing.xxxl;
  @override
  double get huge => JustSpacing.huge;
}

final class FluidSpacingScheme extends JustSpacingScheme {
  final double width;

  const FluidSpacingScheme({this.width = 1024.0});

  @override
  JustSpacingScheme resolve(double width) => FluidSpacingScheme(width: width);

  double _fluid(double minSize, double maxSize) {
    const double minWidth = 640.0;
    const double maxWidth = 1024.0;
    final clampedWidth = width.clamp(minWidth, maxWidth);
    final slope = (maxSize - minSize) / (maxWidth - minWidth);
    return minSize + slope * (clampedWidth - minWidth);
  }

  @override
  double get xxs => _fluid(1.5, 2.0);
  @override
  double get xs => _fluid(3.0, 4.0);
  @override
  double get sm => _fluid(6.0, 8.0);
  @override
  double get md => _fluid(9.0, 12.0);
  @override
  double get lg => _fluid(12.0, 16.0);
  @override
  double get xl => _fluid(18.0, 24.0);
  @override
  double get xxl => _fluid(24.0, 32.0);
  @override
  double get xxxl => _fluid(36.0, 48.0);
  @override
  double get huge => _fluid(48.0, 64.0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluidSpacingScheme &&
          runtimeType == other.runtimeType &&
          width == other.width;

  @override
  int get hashCode => width.hashCode;
}

import 'package:flutter/painting.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

/// Defines the corner rounding values configuration.
abstract final class JustRadiusScheme {
  /// Base constructor.
  const JustRadiusScheme();

  /// Sharp corners.
  Radius get none;

  /// Extra small corner rounding.
  Radius get xs;

  /// Small corner rounding.
  Radius get sm;

  /// Medium corner rounding.
  Radius get md;

  /// Large corner rounding.
  Radius get lg;

  /// Extra large corner rounding.
  Radius get xl;

  /// Double extra large corner rounding.
  Radius get xxl;

  /// Fully rounded pill shape.
  Radius get full;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustRadiusScheme &&
        other.none == none &&
        other.xs == xs &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl &&
        other.xxl == xxl &&
        other.full == full;
  }

  @override
  int get hashCode {
    return Object.hashAll([none, xs, sm, md, lg, xl, xxl, full]);
  }

  /// Resolves the radius scheme for a given screen width. Defaults to returning itself.
  JustRadiusScheme resolve(double width) => this;
}

final class DefaultRadiusScheme extends JustRadiusScheme {
  const DefaultRadiusScheme();

  @override
  Radius get none => JustRadius.none;
  @override
  Radius get xs => JustRadius.xs;
  @override
  Radius get sm => JustRadius.sm;
  @override
  Radius get md => JustRadius.md;
  @override
  Radius get lg => JustRadius.lg;
  @override
  Radius get xl => JustRadius.xl;
  @override
  Radius get xxl => JustRadius.xxl;
  @override
  Radius get full => JustRadius.full;
}

final class FluidRadiusScheme extends JustRadiusScheme {
  final double width;

  const FluidRadiusScheme({this.width = 1024.0});

  @override
  JustRadiusScheme resolve(double width) => FluidRadiusScheme(width: width);

  Radius _fluid(double minSize, double maxSize) {
    const double minWidth = 640.0;
    const double maxWidth = 1024.0;
    final clampedWidth = width.clamp(minWidth, maxWidth);
    final slope = (maxSize - minSize) / (maxWidth - minWidth);
    final calculatedSize = minSize + slope * (clampedWidth - minWidth);
    return .circular(calculatedSize);
  }

  @override
  Radius get none => .zero;
  @override
  Radius get xs => _fluid(1.5, 2.0);
  @override
  Radius get sm => _fluid(3.0, 4.0);
  @override
  Radius get md => _fluid(6.0, 8.0);
  @override
  Radius get lg => _fluid(8.0, 12.0);
  @override
  Radius get xl => _fluid(12.0, 16.0);
  @override
  Radius get xxl => _fluid(16.0, 24.0);
  @override
  Radius get full => const Radius.circular(9999.0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FluidRadiusScheme &&
          runtimeType == other.runtimeType &&
          width == other.width;

  @override
  int get hashCode => width.hashCode;
}

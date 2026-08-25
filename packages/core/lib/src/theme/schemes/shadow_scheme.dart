import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

/// Defines the box shadows configurations.
abstract final class JustShadowScheme {
  /// Base constructor.
  const JustShadowScheme();

  /// Extra small shadow.
  List<BoxShadow> get xs;

  /// Small shadow.
  List<BoxShadow> get sm;

  /// Medium shadow.
  List<BoxShadow> get md;

  /// Large shadow.
  List<BoxShadow> get lg;

  /// Extra large shadow.
  List<BoxShadow> get xl;

  /// Double extra large shadow.
  List<BoxShadow> get xxl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustShadowScheme &&
        listEquals(other.xs, xs) &&
        listEquals(other.sm, sm) &&
        listEquals(other.md, md) &&
        listEquals(other.lg, lg) &&
        listEquals(other.xl, xl) &&
        listEquals(other.xxl, xxl);
  }

  @override
  int get hashCode {
    return Object.hash(
      .hashAll(xs),
      .hashAll(sm),
      .hashAll(md),
      .hashAll(lg),
      .hashAll(xl),
      .hashAll(xxl),
    );
  }
}

final class DefaultShadowSchemeLight extends JustShadowScheme {
  const DefaultShadowSchemeLight();

  @override
  List<BoxShadow> get xs => JustShadows.xs;
  @override
  List<BoxShadow> get sm => JustShadows.sm;
  @override
  List<BoxShadow> get md => JustShadows.md;
  @override
  List<BoxShadow> get lg => JustShadows.lg;
  @override
  List<BoxShadow> get xl => JustShadows.xl;
  @override
  List<BoxShadow> get xxl => JustShadows.xxl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DefaultShadowSchemeLight;

  @override
  int get hashCode => const Symbol('DefaultShadowSchemeLight').hashCode;
}

final class DefaultShadowSchemeDark extends JustShadowScheme {
  const DefaultShadowSchemeDark();

  @override
  List<BoxShadow> get xs => JustShadows.xsDark;
  @override
  List<BoxShadow> get sm => JustShadows.smDark;
  @override
  List<BoxShadow> get md => JustShadows.mdDark;
  @override
  List<BoxShadow> get lg => JustShadows.lgDark;
  @override
  List<BoxShadow> get xl => JustShadows.xlDark;
  @override
  List<BoxShadow> get xxl => JustShadows.xxlDark;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DefaultShadowSchemeDark;

  @override
  int get hashCode => const Symbol('DefaultShadowSchemeDark').hashCode;
}

final class const TintedShadowScheme({
  required final Color seedColor,
  required final bool isDark,
}) extends JustShadowScheme {
  @override
  List<BoxShadow> get xs =>
      JustShadows.generate(seedColor: seedColor, elevation: 1, isDark: isDark);
  @override
  List<BoxShadow> get sm =>
      JustShadows.generate(seedColor: seedColor, elevation: 2, isDark: isDark);
  @override
  List<BoxShadow> get md =>
      JustShadows.generate(seedColor: seedColor, elevation: 4, isDark: isDark);
  @override
  List<BoxShadow> get lg =>
      JustShadows.generate(seedColor: seedColor, elevation: 8, isDark: isDark);
  @override
  List<BoxShadow> get xl =>
      JustShadows.generate(seedColor: seedColor, elevation: 16, isDark: isDark);
  @override
  List<BoxShadow> get xxl =>
      JustShadows.generate(seedColor: seedColor, elevation: 24, isDark: isDark);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TintedShadowScheme &&
          seedColor == other.seedColor &&
          isDark == other.isDark;

  @override
  int get hashCode => Object.hash(seedColor, isDark);
}

final class const NeobrutalismShadowScheme({
  final Color shadowColor = const Color(0xFF000000),
}) extends JustShadowScheme {
  @override
  List<BoxShadow> get xs => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(2.0, 2.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get sm => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(4.0, 4.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get md => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(6.0, 6.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get lg => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(8.0, 8.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get xl => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(10.0, 10.0),
      blurRadius: 0.0,
    ),
  ];
  @override
  List<BoxShadow> get xxl => [
    BoxShadow(
      color: shadowColor,
      offset: const Offset(12.0, 12.0),
      blurRadius: 0.0,
    ),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NeobrutalismShadowScheme && shadowColor == other.shadowColor;

  @override
  int get hashCode => shadowColor.hashCode;
}

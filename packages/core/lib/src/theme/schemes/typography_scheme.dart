import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';

/// Defines the typography styles configuration.
abstract class JustTypographyScheme {
  /// Base constructor.
  const JustTypographyScheme();

  /// Creates a default typography scheme, optionally overriding default font families.
  const factory JustTypographyScheme.fromFontFamily({
    String fontFamily,
    List<String> fontFamilyFallback,
    String monoFontFamily,
    List<String> monoFontFamilyFallback,
  }) = DefaultTypographyScheme;

  /// Large display text.
  TextStyle get displayLg;

  /// Medium display text.
  TextStyle get displayMd;

  /// Small display text.
  TextStyle get displaySm;

  /// Large heading text.
  TextStyle get headingLg;

  /// Medium heading text.
  TextStyle get headingMd;

  /// Small heading text.
  TextStyle get headingSm;

  /// Large body text.
  TextStyle get bodyLg;

  /// Default body text.
  TextStyle get bodyMd;

  /// Small body text.
  TextStyle get bodySm;

  /// Caption text.
  TextStyle get caption;

  /// Overline text.
  TextStyle get overline;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JustTypographyScheme &&
        other.displayLg == displayLg &&
        other.displayMd == displayMd &&
        other.displaySm == displaySm &&
        other.headingLg == headingLg &&
        other.headingMd == headingMd &&
        other.headingSm == headingSm &&
        other.bodyLg == bodyLg &&
        other.bodyMd == bodyMd &&
        other.bodySm == bodySm &&
        other.caption == caption &&
        other.overline == overline;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      displayLg,
      displayMd,
      displaySm,
      headingLg,
      headingMd,
      headingSm,
      bodyLg,
      bodyMd,
      bodySm,
      caption,
      overline,
    ]);
  }
}

/// Default typography scheme allowing custom font families and fallback chains.
final class DefaultTypographyScheme extends JustTypographyScheme {
  final String fontFamily;
  final List<String>? fontFamilyFallback;
  final String monoFontFamily;
  final List<String>? monoFontFamilyFallback;

  const DefaultTypographyScheme({
    this.fontFamily = JustTypo.fontFamily,
    this.fontFamilyFallback = JustTypo.fontFamilyFallback,
    this.monoFontFamily = JustTypo.monoFontFamily,
    this.monoFontFamilyFallback = JustTypo.monoFontFamilyFallback,
  });

  TextStyle _apply(TextStyle base) => base.copyWith(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
  );

  @override
  TextStyle get displayLg => _apply(JustTypo.displayLg);
  @override
  TextStyle get displayMd => _apply(JustTypo.displayMd);
  @override
  TextStyle get displaySm => _apply(JustTypo.displaySm);
  @override
  TextStyle get headingLg => _apply(JustTypo.headingLg);
  @override
  TextStyle get headingMd => _apply(JustTypo.headingMd);
  @override
  TextStyle get headingSm => _apply(JustTypo.headingSm);
  @override
  TextStyle get bodyLg => _apply(JustTypo.bodyLg);
  @override
  TextStyle get bodyMd => _apply(JustTypo.bodyMd);
  @override
  TextStyle get bodySm => _apply(JustTypo.bodySm);
  @override
  TextStyle get caption => _apply(JustTypo.caption);
  @override
  TextStyle get overline => _apply(JustTypo.overline);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefaultTypographyScheme &&
          fontFamily == other.fontFamily &&
          listEquals(fontFamilyFallback, other.fontFamilyFallback) &&
          monoFontFamily == other.monoFontFamily &&
          listEquals(monoFontFamilyFallback, other.monoFontFamilyFallback);

  @override
  int get hashCode => Object.hash(
    fontFamily,
    fontFamilyFallback == null ? null : Object.hashAll(fontFamilyFallback!),
    monoFontFamily,
    monoFontFamilyFallback == null
        ? null
        : Object.hashAll(monoFontFamilyFallback!),
  );
}

/// Typedef for backwards compatibility.
typedef JustCustomTypographyScheme = DefaultTypographyScheme;

import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Dummy target class for Widgetbook Annotation mapping
// =============================================================================
abstract final class JustTokensShowcase {}

// =============================================================================
// 1. COLORS TOKEN USECASE
// =============================================================================
@widgetbook.UseCase(
  name: 'Color Palette & Semantic Schemes',
  type: JustTokensShowcase,
)
Widget buildColorTokensUseCase(BuildContext context) {
  final schemeType = context.knobs.object.dropdown<String>(
    label: 'Color Scheme',
    options: ['Light', 'Dark', 'Neobrutalism Light', 'Neobrutalism Dark'],
    initialOption: 'Light',
  );

  final JustColorScheme scheme;
  switch (schemeType) {
    case 'Dark':
      scheme = JustColors.darkScheme;
      break;
    case 'Neobrutalism Light':
      scheme = JustColors.neobrutalismLightScheme;
      break;
    case 'Neobrutalism Dark':
      scheme = JustColors.neobrutalismDarkScheme;
      break;
    default:
      scheme = JustColors.lightScheme;
      break;
  }

  return Container(
    color: scheme.background,
    padding: const EdgeInsets.all(24.0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semantic Color Tokens ($schemeType)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSwatch('Background', scheme.background, scheme.textPrimary),
              _buildSwatch('Card', scheme.card, scheme.textPrimary),
              _buildSwatch('Elevated', scheme.elevated, scheme.textPrimary),
              _buildSwatch(
                'Text Primary',
                scheme.textPrimary,
                scheme.background,
              ),
              _buildSwatch(
                'Text Secondary',
                scheme.textSecondary,
                scheme.background,
              ),
              _buildSwatch(
                'Border Default',
                scheme.borderDefault,
                scheme.textPrimary,
              ),
              _buildSwatch(
                'Border Focus',
                scheme.borderFocus,
                scheme.textPrimary,
              ),
              _buildSwatch('Success', scheme.success, const Color(0xFFFFFFFF)),
              _buildSwatch('Warning', scheme.warning, const Color(0xFF000000)),
              _buildSwatch('Error', scheme.error, const Color(0xFFFFFFFF)),
              _buildSwatch('Info', scheme.info, const Color(0xFFFFFFFF)),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Raw Palette Shades (Slate / Primary)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMiniSwatch('N50', JustColors.neutral50),
              _buildMiniSwatch('N100', JustColors.neutral100),
              _buildMiniSwatch('N300', JustColors.neutral300),
              _buildMiniSwatch('N500', JustColors.neutral500),
              _buildMiniSwatch('N700', JustColors.neutral700),
              _buildMiniSwatch('N900', JustColors.neutral900),
              _buildMiniSwatch('P50', JustColors.primary50),
              _buildMiniSwatch('P100', JustColors.primary100),
              _buildMiniSwatch('P300', JustColors.primary300),
              _buildMiniSwatch('P500', JustColors.primary500),
              _buildMiniSwatch('P700', JustColors.primary700),
              _buildMiniSwatch('P900', JustColors.primary900),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildSwatch(String label, Color color, Color textColor) {
  final contrast = color.contrastRatioWith(textColor).toStringAsFixed(2);
  final isAA = color.isAccessibleWith(textColor);

  return Container(
    width: 140,
    height: 90,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0x33888888)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$contrast:1',
              style: TextStyle(fontSize: 11, color: textColor),
            ),
            Text(
              isAA ? 'WCAG AA' : 'Fail',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isAA ? textColor : const Color(0xFFFF3B30),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildMiniSwatch(String label, Color color) {
  return Column(
    children: [
      Container(
        width: 44,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x22888888)),
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );
}

// =============================================================================
// 2. TYPOGRAPHY TOKEN USECASE
// =============================================================================
@widgetbook.UseCase(name: 'Typography Scale', type: JustTokensShowcase)
Widget buildTypographyTokensUseCase(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(24.0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Display Large (48px)', style: JustTypo.displayLg),
          SizedBox(height: 12),
          Text('Display Medium (36px)', style: JustTypo.displayMd),
          SizedBox(height: 12),
          Text('Display Small (30px)', style: JustTypo.displaySm),
          SizedBox(height: 24),
          Text('Heading Large (24px)', style: JustTypo.headingLg),
          SizedBox(height: 8),
          Text('Heading Medium (20px)', style: JustTypo.headingMd),
          SizedBox(height: 8),
          Text('Heading Small (16px)', style: JustTypo.headingSm),
          SizedBox(height: 24),
          Text(
            'Body Large (18px) — JustUI component design system tokens.',
            style: JustTypo.bodyLg,
          ),
          SizedBox(height: 8),
          Text(
            'Body Medium (16px) — Standard copy text font scale for general text blocks.',
            style: JustTypo.bodyMd,
          ),
          SizedBox(height: 8),
          Text(
            'Body Small (14px) — Secondary detail descriptions and helper messages.',
            style: JustTypo.bodySm,
          ),
          SizedBox(height: 16),
          Text(
            'Caption (12px) — Annotations and timestamps',
            style: JustTypo.caption,
          ),
          SizedBox(height: 8),
          Text('OVERLINE (11px)', style: JustTypo.overline),
        ],
      ),
    ),
  );
}

// =============================================================================
// 3. SPACING TOKEN USECASE
// =============================================================================
@widgetbook.UseCase(name: 'Spacing Grid & Gaps', type: JustTokensShowcase)
Widget buildSpacingTokensUseCase(BuildContext context) {
  final spacings = <String, double>{
    'xxs (2px)': JustSpacing.xxs,
    'xs (4px)': JustSpacing.xs,
    'sm (8px)': JustSpacing.sm,
    'md (12px)': JustSpacing.md,
    'lg (16px)': JustSpacing.lg,
    'xl (24px)': JustSpacing.xl,
    'xxl (32px)': JustSpacing.xxl,
    'xxxl (48px)': JustSpacing.xxxl,
    'huge (64px)': JustSpacing.huge,
  };

  return Container(
    padding: const EdgeInsets.all(24.0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: spacings.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    e.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  width: e.value,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${e.value}px',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ),
  );
}

// =============================================================================
// 4. RADIUS TOKEN USECASE
// =============================================================================
@widgetbook.UseCase(name: 'Border Radius Tokens', type: JustTokensShowcase)
Widget buildRadiusTokensUseCase(BuildContext context) {
  final radii = <String, BorderRadius>{
    'none (0px)': JustBorderRadius.none,
    'xs (2px)': JustBorderRadius.xs,
    'sm (4px)': JustBorderRadius.sm,
    'md (8px)': JustBorderRadius.md,
    'lg (12px)': JustBorderRadius.lg,
    'xl (16px)': JustBorderRadius.xl,
    'xxl (24px)': JustBorderRadius.xxl,
    'full (pill)': JustBorderRadius.full,
  };

  return Container(
    padding: const EdgeInsets.all(24.0),
    child: SingleChildScrollView(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: radii.entries.map((e) {
          return Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: e.value,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ),
  );
}

// =============================================================================
// 5. SHADOWS TOKEN USECASE
// =============================================================================
@widgetbook.UseCase(name: 'Shadow Multi-Layer Depths', type: JustTokensShowcase)
Widget buildShadowsTokensUseCase(BuildContext context) {
  final shadowMap = <String, List<BoxShadow>>{
    'xs': JustShadows.xs,
    'sm': JustShadows.sm,
    'md': JustShadows.md,
    'lg': JustShadows.lg,
    'xl': JustShadows.xl,
    'xxl': JustShadows.xxl,
  };

  return Container(
    padding: const EdgeInsets.all(32.0),
    child: SingleChildScrollView(
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: shadowMap.entries.map((e) {
          return Container(
            width: 110,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: e.value,
            ),
            child: Center(
              child: Text(
                'Shadow ${e.key.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}

// =============================================================================
// 6. MOTION & DURATION TOKEN USECASE
// =============================================================================
@widgetbook.UseCase(
  name: 'Animation Durations & Motion Curves',
  type: JustTokensShowcase,
)
Widget buildMotionTokensUseCase(BuildContext context) {
  return const _MotionDemoWidget();
}

class _MotionDemoWidget extends StatefulWidget {
  const _MotionDemoWidget();

  @override
  State<_MotionDemoWidget> createState() => _MotionDemoWidgetState();
}

class _MotionDemoWidgetState extends State<_MotionDemoWidget> {
  bool _moved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _moved = !_moved;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tap to Trigger Motion Demos',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildMotionRow(
            'Fast (150ms)',
            JustDuration.fast,
            JustCurves.default_,
          ),
          _buildMotionRow(
            'Normal (250ms)',
            JustDuration.normal,
            JustCurves.enter,
          ),
          _buildMotionRow('Slow (400ms)', JustDuration.slow, JustCurves.exit),
          _buildMotionRow(
            'Spring Bounce',
            JustDuration.slow,
            JustCurves.spring,
          ),
        ],
      ),
    );
  }

  Widget _buildMotionRow(String label, Duration duration, Curve curve) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            height: 36,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: duration,
                  curve: curve,
                  left: _moved ? 250 : 0,
                  top: 2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

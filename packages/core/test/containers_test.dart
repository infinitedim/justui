import 'package:flutter/material.dart'
    show Colors, Icons, MaterialApp, Scaffold, ThemeData;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar_group.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar_style.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar_variants.dart';
import 'package:just_ui_core/src/components/badge/just_badge.dart';
import 'package:just_ui_core/src/components/badge/just_badge_style.dart';
import 'package:just_ui_core/src/components/badge/just_badge_variants.dart';
import 'package:just_ui_core/src/components/card/just_card.dart';
import 'package:just_ui_core/src/components/card/just_card_style.dart';
import 'package:just_ui_core/src/components/card/just_card_theme.dart';
import 'package:just_ui_core/src/components/progress/just_progress.dart';
import 'package:just_ui_core/src/components/progress/just_progress_style.dart';
import 'package:just_ui_core/src/components/progress/just_progress_theme.dart';
import 'package:just_ui_core/src/components/separator/just_separator.dart';
import 'package:just_ui_core/src/components/separator/just_separator_style.dart';
import 'package:just_ui_core/src/components/separator/just_separator_theme.dart';
import 'package:just_ui_core/src/components/skeleton/just_skeleton.dart';
import 'package:just_ui_core/src/components/skeleton/just_skeleton_style.dart';
import 'package:just_ui_core/src/components/skeleton/just_skeleton_theme.dart';

Widget _buildWrapper({
  required Widget child,
  JustThemeData? theme,
  JustCardTheme? cardTheme,
  JustSeparatorTheme? separatorTheme,
  JustSkeletonTheme? skeletonTheme,
  JustProgressTheme? progressTheme,
}) {
  final activeTheme = theme ?? JustThemeData.light;
  return JustThemeProvider(
    lightTheme: activeTheme,
    child: MaterialApp(
      theme: ThemeData(
        extensions: [
          ?cardTheme,
          ?separatorTheme,
          ?skeletonTheme,
          ?progressTheme,
        ],
      ),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // --- JustCard Tests ---
  // =========================================================================
  group('JustCard Widget & Theme Tests', () {
    testWidgets('Renders elevated, outlined, and filled card variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: const Column(
            children: [
              JustCard(child: Text('Default Elevated')),
              JustCard.elevated(child: Text('Elevated Named')),
              JustCard.outlined(child: Text('Outlined Card')),
              JustCard.filled(child: Text('Filled Card')),
            ],
          ),
        ),
      );

      expect(find.text('Default Elevated'), findsOneWidget);
      expect(find.text('Elevated Named'), findsOneWidget);
      expect(find.text('Outlined Card'), findsOneWidget);
      expect(find.text('Filled Card'), findsOneWidget);
    });

    testWidgets(
      'Renders card header, footer, dividers, and composable sub-widgets',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            child: const JustCard(
              header: JustCardHeader(
                child: Column(
                  children: [
                    JustCardTitle(child: Text('Card Title')),
                    JustCardDescription(child: Text('Card Description')),
                  ],
                ),
              ),
              footer: JustCardFooter(child: Text('Card Footer Actions')),
              child: JustCardContent(child: Text('Card Body Content')),
            ),
          ),
        );

        expect(find.text('Card Title'), findsOneWidget);
        expect(find.text('Card Description'), findsOneWidget);
        expect(find.text('Card Body Content'), findsOneWidget);
        expect(find.text('Card Footer Actions'), findsOneWidget);
      },
    );

    testWidgets(
      'Interactive card handles onTap, hover, focus, and press interactions',
      (tester) async {
        int tapCount = 0;
        await tester.pumpWidget(
          _buildWrapper(
            child: JustCard(
              onTap: () => tapCount++,
              style: const JustCardStyle(
                scaleOnPress: 0.95,
                backgroundColor: Colors.white,
              ),
              child: const Text('Clickable Card'),
            ),
          ),
        );

        expect(find.text('Clickable Card'), findsOneWidget);
        await tester.tap(find.text('Clickable Card'));
        await tester.pumpAndSettle();
        expect(tapCount, equals(1));
      },
    );

    testWidgets(
      'JustCard respects per-instance style overrides and neobrutalism theme',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            theme: JustThemeData.neobrutalismLight,
            child: const JustCard(
              style: JustCardStyle(
                backgroundColor: Colors.amber,
                borderColor: Colors.black,
                borderWidth: 3.0,
                borderRadius: .all(.circular(12.0)),
                padding: EdgeInsets.all(24.0),
                margin: EdgeInsets.all(16.0),
              ),
              child: Text('Styled Neo Card'),
            ),
          ),
        );

        expect(find.text('Styled Neo Card'), findsOneWidget);
      },
    );

    test('JustCardTheme copyWith and lerp', () {
      const theme1 = JustCardTheme(
        style: JustCardStyle(backgroundColor: Colors.red),
      );
      const theme2 = JustCardTheme(
        style: JustCardStyle(backgroundColor: Colors.blue),
      );

      final copied = theme1.copyWith(
        style: const JustCardStyle(backgroundColor: Colors.green),
      );
      expect(copied.style?.backgroundColor, equals(Colors.green));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustCardTheme.defaults.style, isNull);
    });
  });

  // =========================================================================
  // --- JustSeparator Tests ---
  // =========================================================================
  group('JustSeparator Widget & Theme Tests', () {
    testWidgets(
      'Renders horizontal and vertical separators with and without labels',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            child: const Column(
              children: [
                JustSeparator(),
                JustSeparator(label: 'OR'),
                SizedBox(
                  height: 100,
                  child: JustSeparator(
                    direction: Axis.vertical,
                    thickness: 2.0,
                    indent: 8.0,
                    endIndent: 8.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );

        expect(find.byType(JustSeparator), findsNWidgets(3));
        expect(find.text('OR'), findsOneWidget);
      },
    );

    testWidgets(
      'Responsive separator switches orientation based on screen width',
      (tester) async {
        tester.view.physicalSize = const Size(
          500,
          800,
        ); // Below 640 breakpoint -> horizontal
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          _buildWrapper(
            child: const JustSeparator.responsive(
              breakpoint: 640.0,
              label: 'Responsive',
            ),
          ),
        );

        expect(find.text('Responsive'), findsOneWidget);
      },
    );

    testWidgets('JustSeparator respects style overrides and theme data', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          separatorTheme: const JustSeparatorTheme(
            style: JustSeparatorStyle(
              thickness: 4.0,
              color: Colors.red,
              indent: 10.0,
              endIndent: 10.0,
              labelStyle: TextStyle(fontSize: 16.0, color: Colors.blue),
              labelPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
          ),
          child: const JustSeparator(label: 'Styled'),
        ),
      );

      expect(find.text('Styled'), findsOneWidget);
    });

    test('JustSeparatorTheme copyWith and lerp', () {
      const theme1 = JustSeparatorTheme(
        style: JustSeparatorStyle(thickness: 1.0),
      );
      const theme2 = JustSeparatorTheme(
        style: JustSeparatorStyle(thickness: 3.0),
      );

      final copied = theme1.copyWith(
        style: const JustSeparatorStyle(thickness: 2.0),
      );
      expect(copied.style?.thickness, equals(2.0));

      expect(theme1.lerp(theme2, 0.3), equals(theme1));
      expect(theme1.lerp(theme2, 0.7), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustSeparatorTheme.defaults.style, isNull);
    });
  });

  // =========================================================================
  // --- JustBadge Tests ---
  // =========================================================================
  group('JustBadge Widget Tests', () {
    testWidgets('Renders all badge visual variants and color categories', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: Column(
            children: [
              for (final color in JustBadgeColor.values)
                JustBadge(
                  label: 'Badge ${color.name}',
                  color: color,
                  variant: JustBadgeVariant.solid,
                ),
              const JustBadge(
                label: 'Outline',
                variant: JustBadgeVariant.outline,
              ),
              const JustBadge(label: 'Soft', variant: JustBadgeVariant.soft),
              const JustBadge.dot(color: JustBadgeColor.success),
            ],
          ),
        ),
      );

      expect(find.text('Badge primary'), findsOneWidget);
      expect(find.text('Badge error'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('Soft'), findsOneWidget);
    });

    testWidgets(
      'Badge leading icon, sizes, maxWidth truncation, and onDismiss button',
      (tester) async {
        int dismissedCount = 0;
        await tester.pumpWidget(
          _buildWrapper(
            child: Column(
              children: [
                const JustBadge(
                  label: 'Small Badge',
                  size: JustBadgeSize.sm,
                  leading: Icon(Icons.star, size: 12),
                ),
                const JustBadge(
                  label: 'Large Badge',
                  size: JustBadgeSize.lg,
                  maxWidth: 60.0,
                ),
                JustBadge(
                  label: 'Dismissable',
                  onDismiss: () => dismissedCount++,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Small Badge'), findsOneWidget);
        expect(find.text('Large Badge'), findsOneWidget);
        expect(find.text('Dismissable'), findsOneWidget);

        await tester.tap(find.byType(GestureDetector).last);
        await tester.pumpAndSettle();
        expect(dismissedCount, equals(1));
      },
    );

    testWidgets(
      'JustBadge.overlay positions badge at various corner alignments',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            child: Column(
              children: [
                for (final pos in BadgePosition.values)
                  JustBadge.overlay(
                    position: pos,
                    badge: const JustBadge.dot(),
                    child: const SizedBox(width: 40, height: 40),
                  ),
              ],
            ),
          ),
        );

        expect(
          find.byType(JustBadge),
          findsNWidgets(BadgePosition.values.length),
        );
      },
    );

    testWidgets('JustBadge respects custom style overrides', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: const JustBadge(
            label: 'Custom Style',
            style: JustBadgeStyle(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              borderColor: Colors.black,
              borderRadius: .all(.circular(6.0)),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ),
        ),
      );

      expect(find.text('Custom Style'), findsOneWidget);
    });
  });

  // =========================================================================
  // --- JustAvatar & JustAvatarGroup Tests ---
  // =========================================================================
  group('JustAvatar & JustAvatarGroup Widget Tests', () {
    testWidgets('Renders name initials, fallback icon, and image avatar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: const Column(
            children: [
              JustAvatar(name: 'John Doe'),
              JustAvatar(name: 'SingleName'),
              JustAvatar(name: ''),
              JustAvatar(icon: Icons.person),
              JustAvatar(), // Default fallback painter
            ],
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Renders all avatar sizes, shapes, and status dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: Column(
            children: [
              for (final size in JustAvatarSize.values)
                JustAvatar(
                  name: 'Alice Brown',
                  size: size,
                  shape: JustAvatarShape.rounded,
                  statusDot: JustAvatarStatus.online,
                ),
              const JustAvatar(
                name: 'Away User',
                statusDot: JustAvatarStatus.away,
              ),
              const JustAvatar(
                name: 'Busy User',
                statusDot: JustAvatarStatus.busy,
              ),
              const JustAvatar(
                name: 'Offline User',
                statusDot: JustAvatarStatus.offline,
              ),
            ],
          ),
        ),
      );

      expect(find.text('AB'), findsNWidgets(JustAvatarSize.values.length));
    });

    testWidgets('Avatar is interactive when onTap is provided', (tester) async {
      int avatarTaps = 0;
      await tester.pumpWidget(
        _buildWrapper(
          child: JustAvatar(
            name: 'Tap Me',
            onTap: () => avatarTaps++,
            style: const JustAvatarStyle(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              borderColor: Colors.black,
              borderWidth: 2.0,
            ),
          ),
        ),
      );

      expect(find.text('TM'), findsOneWidget);
      await tester.tap(find.text('TM'));
      await tester.pumpAndSettle();
      expect(avatarTaps, equals(1));
    });

    testWidgets(
      'JustAvatarGroup renders stacked avatars with max display limit',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            child: const Column(
              children: [
                JustAvatarGroup(avatars: []),
                JustAvatarGroup(
                  maxDisplay: 2,
                  avatars: [
                    JustAvatar(name: 'Alice Alpha'),
                    JustAvatar(name: 'Bob Beta'),
                    JustAvatar(name: 'Charlie Charlie'),
                    JustAvatar(name: 'David Delta'),
                  ],
                ),
              ],
            ),
          ),
        );

        expect(find.text('AA'), findsOneWidget);
        expect(find.text('BB'), findsOneWidget);
        expect(find.byKey(const ValueKey('remaining_avatar')), findsOneWidget);
      },
    );

    test('PersonFallbackPainter shouldRepaint logic', () {
      const p1 = PersonFallbackPainter(color: Colors.red);
      const p2 = PersonFallbackPainter(color: Colors.red);
      const p3 = PersonFallbackPainter(color: Colors.blue);

      expect(p1.shouldRepaint(p2), isFalse);
      expect(p1.shouldRepaint(p3), isTrue);
    });
  });

  // =========================================================================
  // --- JustSkeleton Tests ---
  // =========================================================================
  group('JustSkeleton Widget & Theme Tests', () {
    testWidgets(
      'Structure-aware skeleton replaces leaf widgets when loading is true',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            child: const JustSkeleton(
              loading: true,
              child: Column(
                children: [
                  Text('Real Heading'),
                  Text('Real Body Paragraph Description'),
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: Text('Action Button'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(JustSkeleton), findsOneWidget);

        // Rebuild with loading: false to see original child tree
        await tester.pumpWidget(
          _buildWrapper(
            child: const JustSkeleton(
              loading: false,
              child: Text('Real Content'),
            ),
          ),
        );

        expect(find.text('Real Content'), findsOneWidget);
      },
    );

    testWidgets('Manual skeleton constructors: text, circle, rect', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: const Column(
            children: [
              JustSkeleton.text(width: 120, height: 16),
              JustSkeleton.circle(size: 48),
              JustSkeleton.rect(width: 200, height: 80),
            ],
          ),
        ),
      );

      expect(find.byType(JustSkeleton), findsNWidgets(3));
    });

    testWidgets('JustSkeletonIgnore and JustSkeletonAtomic escape hatches', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: const JustSkeleton(
            loading: true,
            child: Column(
              children: [
                JustSkeletonIgnore(child: Text('Ignored Always Visible')),
                JustSkeletonAtomic(
                  width: 150,
                  height: 50,
                  child: Text('Atomic Skeleton Block'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Ignored Always Visible'), findsOneWidget);
    });

    testWidgets('JustSkeleton respects style overrides and theme data', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          skeletonTheme: const JustSkeletonTheme(
            style: JustSkeletonStyle(
              backgroundColor: Colors.grey,
              shimmerColor: Colors.white,
              duration: Duration(milliseconds: 1200),
            ),
          ),
          child: const JustSkeleton.text(width: 100, height: 20),
        ),
      );

      expect(find.byType(JustSkeleton), findsOneWidget);
    });

    test('JustSkeletonTheme copyWith and lerp', () {
      const theme1 = JustSkeletonTheme(
        style: JustSkeletonStyle(backgroundColor: Colors.black12),
      );
      const theme2 = JustSkeletonTheme(
        style: JustSkeletonStyle(backgroundColor: Colors.black26),
      );

      final copied = theme1.copyWith(
        style: const JustSkeletonStyle(backgroundColor: Colors.black38),
      );
      expect(copied.style?.backgroundColor, equals(Colors.black38));

      expect(theme1.lerp(theme2, 0.2), equals(theme1));
      expect(theme1.lerp(theme2, 0.8), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustSkeletonTheme.defaults.style, isNull);
    });
  });

  // =========================================================================
  // --- JustProgress Tests ---
  // =========================================================================
  group('JustProgress Widget & Theme Tests', () {
    testWidgets(
      'Renders determinate and indeterminate linear and circular progress',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            child: const Column(
              children: [
                JustProgress(value: 0.6, showLabel: true),
                JustProgress.circular(
                  value: 0.75,
                  showLabel: true,
                  label: '75% Done',
                ),
                JustProgress(value: null), // Indeterminate linear
                JustProgress.circular(value: null), // Indeterminate circular
              ],
            ),
          ),
        );

        expect(find.text('60%'), findsOneWidget);
        expect(find.text('75% Done'), findsOneWidget);
        expect(find.byType(JustProgress), findsNWidgets(4));
      },
    );

    testWidgets('Renders all progress sizes and respects style overrides', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(
          progressTheme: const JustProgressTheme(
            style: JustProgressStyle(
              trackColor: Colors.grey,
              fillColor: Colors.blue,
              labelColor: Colors.black,
              strokeWidth: 4.0,
            ),
          ),
          child: Column(
            children: [
              for (final size in JustProgressSize.values) ...[
                JustProgress(value: 0.5, size: size),
                JustProgress.circular(value: 0.5, size: size),
              ],
            ],
          ),
        ),
      );

      expect(
        find.byType(JustProgress),
        findsNWidgets(JustProgressSize.values.length * 2),
      );
    });

    testWidgets('Progress updates value dynamically', (tester) async {
      double currentVal = 0.2;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _buildWrapper(
              child: Column(
                children: [
                  JustProgress(value: currentVal, showLabel: true),
                  GestureDetector(
                    onTap: () => setState(() => currentVal = 0.8),
                    child: const Text('Update Progress'),
                  ),
                ],
              ),
            );
          },
        ),
      );

      expect(find.text('20%'), findsOneWidget);
      await tester.tap(find.text('Update Progress'));
      await tester.pumpAndSettle();
      expect(find.text('80%'), findsOneWidget);
    });

    test('JustProgressTheme copyWith and lerp', () {
      const theme1 = JustProgressTheme(
        style: JustProgressStyle(fillColor: Colors.blue),
      );
      const theme2 = JustProgressTheme(
        style: JustProgressStyle(fillColor: Colors.purple),
      );

      final copied = theme1.copyWith(
        style: const JustProgressStyle(fillColor: Colors.amber),
      );
      expect(copied.style?.fillColor, equals(Colors.amber));

      expect(theme1.lerp(theme2, 0.4), equals(theme1));
      expect(theme1.lerp(theme2, 0.6), equals(theme2));
      expect(theme1.lerp(null, 0.5), equals(theme1));
      expect(JustProgressTheme.defaults.style, isNull);
    });
  });
}

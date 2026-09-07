// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/badge/just_badge.dart';
import 'package:just_ui_core/src/components/badge/just_badge_variants.dart';
import 'package:just_ui_core/src/components/scroll/just_scroll_area.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default Scroll Area', type: JustScrollArea)
Widget buildJustScrollAreaDefaultUseCase(BuildContext context) {
  final fadeEdges = context.knobs.boolean(
    label: 'Fade Edges',
    initialValue: true,
  );
  final showScrollbar = context.knobs.boolean(
    label: 'Show Scrollbar',
    initialValue: true,
  );
  final scrollToTopButton = context.knobs.boolean(
    label: 'Scroll to Top Button',
    initialValue: true,
  );
  final smoothScroll = context.knobs.boolean(
    label: 'Smooth Scroll (Lenis)',
    initialValue: true,
  );
  final lerpFactor = context.knobs.double.slider(
    label: 'Lerp Factor',
    initialValue: 0.10,
    min: 0.01,
    max: 0.5,
  );
  final wheelMultiplier = context.knobs.double.slider(
    label: 'Wheel Multiplier',
    initialValue: 1.0,
    min: 0.5,
    max: 3.0,
  );
  final maxHeight = context.knobs.double.slider(
    label: 'Container Height',
    initialValue: 420.0,
    min: 250.0,
    max: 600.0,
  );

  final colors = context.justColors;
  final typo = context.justTypo;
  final spacing = context.justSpacing;

  final activityData = [
    (
      iconColor: const Color(0xFF10B981), // Emerald
      badgeText: 'Deploy',
      title: 'Production Build #482 Deployed',
      subtitle: 'Triggered by @sarah_connor • Commit 7f9a12c',
      time: '2m ago',
    ),
    (
      iconColor: const Color(0xFF3B82F6), // Blue
      badgeText: 'Security',
      title: 'OAuth2 Tokens Rotated Successfully',
      subtitle: 'Automatic security policy enforcement cycle',
      time: '14m ago',
    ),
    (
      iconColor: const Color(0xFF8B5CF6), // Purple
      badgeText: 'Database',
      title: 'Automated Snapshot Backup Complete',
      subtitle: 'Region us-east-1 • 4.2 GB archived to S3',
      time: '45m ago',
    ),
    (
      iconColor: const Color(0xFFF59E0B), // Amber
      badgeText: 'Alert',
      title: 'High API Latency Spike Detected',
      subtitle: 'Endpoint /api/v1/analytics exceeded 450ms p99',
      time: '1h ago',
    ),
    (
      iconColor: const Color(0xFFEC4899), // Pink
      badgeText: 'Release',
      title: 'JustUI Core v0.12.2 Published',
      subtitle: 'Added Lenis smooth scroll engine & contrast auditor',
      time: '2h ago',
    ),
    (
      iconColor: const Color(0xFF06B6D4), // Cyan
      badgeText: 'Team',
      title: 'Alex Rivera Joined Development Team',
      subtitle: 'Assigned Senior Frontend Architect role',
      time: '3h ago',
    ),
    (
      iconColor: const Color(0xFF6366F1), // Indigo
      badgeText: 'Billing',
      title: 'Stripe Webhook Event Received',
      subtitle: 'Invoice #INV-2026-089 paid successfully',
      time: '5h ago',
    ),
    (
      iconColor: const Color(0xFF10B981), // Emerald
      badgeText: 'CI/CD',
      title: 'Workflow Tests Passed (124/124)',
      subtitle: 'Ran in 42s on Linux x64 runner',
      time: '6h ago',
    ),
    (
      iconColor: const Color(0xFFEF4444), // Red
      badgeText: 'Audit',
      title: 'Failed Login Attempt Blocked',
      subtitle: 'IP 192.168.1.104 flagged by rate limiter',
      time: '8h ago',
    ),
    (
      iconColor: const Color(0xFF8B5CF6), // Purple
      badgeText: 'Cache',
      title: 'Redis Cluster Memory Purged',
      subtitle: 'Freed 1.2 GB of stale session keys',
      time: '12h ago',
    ),
    (
      iconColor: const Color(0xFF3B82F6), // Blue
      badgeText: 'Storage',
      title: 'CDN Edge Nodes Synced',
      subtitle: 'Invalidated 14 cache paths globally',
      time: '1d ago',
    ),
    (
      iconColor: const Color(0xFF10B981), // Emerald
      badgeText: 'Domain',
      title: 'SSL Certificate Auto-Renewed',
      subtitle: 'Valid for api.justui.dev until Aug 2027',
      time: '2d ago',
    ),
  ];

  return Center(
    child: Container(
      width: 440.0,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const .all(Radius.circular(12.0)),
        border: .all(color: colors.borderDefault, width: 1.0),
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Row(
              children: [
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Text(
                  'Activity & Audit Log',
                  style: typo.headingSm.copyWith(
                    color: colors.textPrimary,
                    fontWeight: .w600,
                  ),
                ),
                const Spacer(),
                JustBadge(
                  label: '${activityData.length} Events',
                  color: JustBadgeColor.secondary,
                  variant: JustBadgeVariant.soft,
                ),
              ],
            ),
          ),
          Container(height: 1.0, color: colors.borderDefault),
          // Scrollable Content
          JustScrollArea(
            maxHeight: maxHeight,
            fadeEdges: fadeEdges,
            showScrollbar: showScrollbar,
            scrollToTopButton: scrollToTopButton,
            smoothScroll: smoothScroll,
            lerpFactor: lerpFactor,
            wheelMultiplier: wheelMultiplier,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            child: Column(
              children: .generate(activityData.length, (index) {
                final item = activityData[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.xs),
                  child: Container(
                    padding: EdgeInsets.all(spacing.md),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: const .all(Radius.circular(8.0)),
                      border: .all(
                        color: colors.borderDefault.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: .start,
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                color: item.iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: typo.bodySm.copyWith(
                                        color: colors.textPrimary,
                                        fontWeight: .w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.time,
                                    style: typo.caption.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing.xs),
                              Text(
                                item.subtitle,
                                style: typo.caption.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ),
  );
}

// ignore_for_file: implementation_imports
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:just_ui_core/src/components/skeleton/just_skeleton.dart';
import 'package:just_ui_core/src/components/card/just_card.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';

@widgetbook.UseCase(name: 'Structure-Aware Skeleton', type: JustSkeleton)
Widget buildJustSkeletonDefaultUseCase(BuildContext context) {
  final loading = context.knobs.boolean(
    label: 'Loading State',
    initialValue: true,
  );

  return SizedBox(
    width: 340.0,
    child: JustSkeleton(
      loading: loading,
      child: JustCard(
        header: const JustCardHeader(
          child: Row(
            children: [
              JustAvatar(name: 'Jane Doe'),
              SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text('Jane Doe', style: TextStyle(fontWeight: .bold)),
                  Text('Software Engineer'),
                ],
              ),
            ],
          ),
        ),
        footer: JustCardFooter(
          child: Row(
            mainAxisAlignment: .end,
            children: [
              JustButton.primary(label: 'View Profile', onPressed: () {}),
            ],
          ),
        ),
        child: const Text(
          'Jane is an expert in Flutter architecture and zero-dependency component design.',
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Manual Shapes', type: JustSkeleton)
Widget buildJustSkeletonManualUseCase(BuildContext context) {
  return const Column(
    mainAxisSize: .min,
    crossAxisAlignment: .start,
    children: [
      JustSkeleton.circle(size: 48.0),
      SizedBox(height: 12.0),
      JustSkeleton.text(width: 200.0, height: 16.0),
      SizedBox(height: 8.0),
      JustSkeleton.text(width: 140.0, height: 14.0),
    ],
  );
}

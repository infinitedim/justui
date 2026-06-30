import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:just_ui_core/src/components/button/just_button.dart';
import 'package:just_ui_core/src/components/badge/just_badge.dart';
import 'package:just_ui_core/src/components/avatar/just_avatar.dart';
import 'package:just_ui_core/src/components/checkbox/just_checkbox.dart';
import 'package:just_ui_core/src/components/radio/just_radio.dart';
import 'package:just_ui_core/src/components/switch/just_switch.dart';
import 'package:just_ui_core/src/components/card/just_card.dart';
import 'package:just_ui_core/src/components/input/just_input.dart';

class ShowcaseGrid extends StatelessWidget {
  const ShowcaseGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final spacing = theme.spacing;

    return Container(
      color: const Color(0x00000000), // Transparent background
      padding: EdgeInsets.all(spacing.md),
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.md,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          _buildCard(
            theme,
            title: 'Buttons',
            child: Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                JustButton.primary(label: 'Primary', onPressed: () {}),
                JustButton.secondary(label: 'Secondary', onPressed: () {}),
                JustButton.destructive(label: 'Danger', onPressed: () {}),
                JustButton.ghost(label: 'Ghost', onPressed: () {}),
              ],
            ),
          ),
          _buildCard(
            theme,
            title: 'Badges',
            child: Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                JustBadge(label: 'Success', color: .success),
                JustBadge(label: 'Warning', color: .warning, variant: .outline),
                JustBadge(label: 'Error', color: .error, variant: .soft),
                JustBadge(label: 'New', color: .primary),
              ],
            ),
          ),
          _buildCard(
            theme,
            title: 'Avatars',
            child: Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                JustAvatar(name: 'John Doe', size: .sm),
                JustAvatar(name: 'Sarah Chen', size: .md),
                JustAvatar(name: 'Alex Rivera', size: .lg),
              ],
            ),
          ),
          _buildCard(
            theme,
            title: 'Inputs & Controls',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const JustInput(label: 'Username', hint: 'enter username'),
                SizedBox(height: spacing.md),
                const InteractiveControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    JustThemeData theme, {
    required String title,
    required Widget child,
  }) {
    final spacing = theme.spacing;
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: JustCard.outlined(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.typography.bodyMd.copyWith(
                fontWeight: .w600,
                color: theme.colors.textPrimary,
              ),
            ),
            SizedBox(height: spacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class InteractiveControls extends StatefulWidget {
  const InteractiveControls({super.key});

  @override
  State<InteractiveControls> createState() => _InteractiveControlsState();
}

class _InteractiveControlsState extends State<InteractiveControls> {
  bool _switchVal = true;
  bool? _checkboxVal = false;
  String _radioVal = 'A';

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final spacing = theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        JustSwitch(
          value: _switchVal,
          label: Text(
            'Switch: ${_switchVal ? "ON" : "OFF"}',
            style: theme.typography.bodySm.copyWith(
              color: theme.colors.textPrimary,
            ),
          ),
          onChanged: (v) => setState(() => _switchVal = v),
        ),
        SizedBox(height: spacing.sm),
        JustCheckbox(
          value: _checkboxVal,
          label: Text(
            'Checkbox',
            style: theme.typography.bodySm.copyWith(
              color: theme.colors.textPrimary,
            ),
          ),
          onChanged: (v) => setState(() => _checkboxVal = v),
        ),
        SizedBox(height: spacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            JustRadio<String>(
              value: 'A',
              groupValue: _radioVal,
              label: Text(
                'Option A',
                style: theme.typography.bodySm.copyWith(
                  color: theme.colors.textPrimary,
                ),
              ),
              onChanged: (v) => setState(() => _radioVal = v),
            ),
            SizedBox(width: spacing.md),
            JustRadio<String>(
              value: 'B',
              groupValue: _radioVal,
              label: Text(
                'Option B',
                style: theme.typography.bodySm.copyWith(
                  color: theme.colors.textPrimary,
                ),
              ),
              onChanged: (v) => setState(() => _radioVal = v),
            ),
          ],
        ),
      ],
    );
  }
}

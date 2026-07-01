import 'package:flutter/widgets.dart';
import 'package:just_ui_core/just_ui_core.dart';
import 'package:showcase/widgets/avatar/just_avatar.dart';
import 'package:showcase/widgets/badge/just_badge.dart';
import 'package:showcase/widgets/button/just_button.dart';
import 'package:showcase/widgets/button/just_button_style.dart';
import 'package:showcase/widgets/checkbox/just_checkbox.dart';
import 'package:showcase/widgets/input/just_input.dart';
import 'package:showcase/widgets/radio/just_radio.dart';
import 'package:showcase/widgets/switch/just_switch.dart';

class ShowcaseMarquee extends StatefulWidget {
  const ShowcaseMarquee({super.key});

  @override
  State<ShowcaseMarquee> createState() => _ShowcaseMarqueeState();
}

class _ShowcaseMarqueeState extends State<ShowcaseMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey _stripKey = GlobalKey();
  double _stripWidth = 1000.0;

  bool _switchVal = true;
  bool? _checkboxVal = false;
  String _radioVal = 'A';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );
    _controller.repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureWidth());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _measureWidth() {
    if (!mounted) return;
    final renderBox =
        _stripKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final width = renderBox.size.width;
      if (width > 0 && width != _stripWidth) {
        setState(() {
          _stripWidth = width;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureWidth());

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(-_controller.value * _stripWidth, 0.0),
            child: Row(
              mainAxisSize: .min,
              children: [
                Container(key: _stripKey, child: _buildComponentStrip(context)),
                _buildComponentStrip(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildComponentStrip(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final spacing = theme.spacing;

    return Row(
      mainAxisSize: .min,
      children: [
        _GroupCard(
          title: 'Buttons',
          child: Row(
            mainAxisSize: .min,
            children: [
              JustButton.primary(label: 'Primary', onPressed: () {}),
              SizedBox(width: spacing.sm),
              JustButton.secondary(
                label: 'Secondary',
                style: JustButtonStyle(
                  textStyle: TextStyle(color: theme.colors.textPrimary),
                ),
                onPressed: () {},
              ),
              SizedBox(width: spacing.sm),
              JustButton.destructive(label: 'Danger', onPressed: () {}),
              SizedBox(width: spacing.sm),
              JustButton.ghost(label: 'Ghost', onPressed: () {}),
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        const _Separator(),
        SizedBox(width: spacing.md),
        _GroupCard(
          title: 'Badges',
          child: Row(
            mainAxisSize: .min,
            children: [
              const JustBadge(
                label: 'Success',
                color: .success,
                variant: .solid,
              ),
              SizedBox(width: spacing.sm),
              const JustBadge(
                label: 'Success',
                color: .success,
                variant: .outline,
              ),
              SizedBox(width: spacing.sm),
              const JustBadge(
                label: 'Success',
                color: .success,
                variant: .soft,
              ),
              SizedBox(width: spacing.sm),
              const JustBadge(
                label: 'Warning',
                color: .warning,
                variant: .outline,
              ),
              SizedBox(width: spacing.sm),
              const JustBadge(label: 'Error', color: .error, variant: .soft),
              SizedBox(width: spacing.sm),
              const JustBadge(label: 'New', color: .primary),
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        const _Separator(),
        SizedBox(width: spacing.md),
        _GroupCard(
          title: 'Avatars',
          child: Row(
            mainAxisSize: .min,
            children: [
              const JustAvatar(name: 'John Doe', size: .sm),
              SizedBox(width: spacing.sm),
              const JustAvatar(name: 'Sarah Chen', size: .md),
              SizedBox(width: spacing.sm),
              const JustAvatar(name: 'Alex Rivera', size: .lg),
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        const _Separator(),
        SizedBox(width: spacing.md),
        _GroupCard(
          title: 'Controls',
          child: _InteractiveControls(
            switchVal: _switchVal,
            checkboxVal: _checkboxVal,
            radioVal: _radioVal,
            onSwitchChanged: (v) => setState(() => _switchVal = v),
            onCheckboxChanged: (v) => setState(() => _checkboxVal = v),
            onRadioChanged: (v) => setState(() => _radioVal = v),
          ),
        ),
        SizedBox(width: spacing.md),
        const _Separator(),
        SizedBox(width: spacing.md),
        _GroupCard(
          title: 'Input',
          child: const SizedBox(
            width: 200.0,
            child: JustInput(label: 'Username', hint: 'enter username'),
          ),
        ),
        SizedBox(width: spacing.md),
        const _Separator(),
        SizedBox(width: spacing.md),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _GroupCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final isNeobrutalism = theme.preset == .neobrutalism;

    final Border border = isNeobrutalism
        ? .all(color: theme.colors.textPrimary, width: 2.5)
        : .all(color: theme.colors.borderDefault, width: 1.0);

    final BorderRadius borderRadius = isNeobrutalism
        ? .zero
        : .all(theme.radius.md);

    final boxShadow = isNeobrutalism
        ? [
            BoxShadow(
              color: theme.colors.textPrimary,
              offset: const Offset(4.0, 4.0),
              blurRadius: 0.0,
              spreadRadius: 0.0,
            ),
          ]
        : null;

    return Container(
      height: 125.0,
      padding: .symmetric(
        horizontal: theme.spacing.md,
        vertical: theme.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colors.card,
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: theme.spacing.xs),
          child,
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final isNeobrutalism = theme.preset == .neobrutalism;
    final width = isNeobrutalism ? 2.5 : 1.0;
    final color = isNeobrutalism
        ? theme.colors.textPrimary
        : theme.colors.borderDefault;

    return Container(width: width, height: 64.0, color: color);
  }
}

class _InteractiveControls extends StatelessWidget {
  final bool switchVal;
  final bool? checkboxVal;
  final String radioVal;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<bool?> onCheckboxChanged;
  final ValueChanged<String> onRadioChanged;

  const _InteractiveControls({
    required this.switchVal,
    required this.checkboxVal,
    required this.radioVal,
    required this.onSwitchChanged,
    required this.onCheckboxChanged,
    required this.onRadioChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = JustThemeProvider.of(context).theme;
    final spacing = theme.spacing;

    return Row(
      mainAxisSize: .min,
      crossAxisAlignment: .center,
      children: [
        JustSwitch(
          value: switchVal,
          label: Text(
            'Switch: ${switchVal ? "ON" : "OFF"}',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: theme.colors.textPrimary,
            ),
          ),
          onChanged: onSwitchChanged,
        ),
        SizedBox(width: spacing.md),
        JustCheckbox(
          value: checkboxVal,
          label: Text(
            'Checkbox',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: theme.colors.textPrimary,
            ),
          ),
          onChanged: onCheckboxChanged,
        ),
        SizedBox(width: spacing.md),
        JustRadio<String>(
          value: 'A',
          groupValue: radioVal,
          label: Text(
            'Option A',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: theme.colors.textPrimary,
            ),
          ),
          onChanged: onRadioChanged,
        ),
        SizedBox(width: spacing.sm),
        JustRadio<String>(
          value: 'B',
          groupValue: radioVal,
          label: Text(
            'Option B',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans',
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: theme.colors.textPrimary,
            ),
          ),
          onChanged: onRadioChanged,
        ),
      ],
    );
  }
}

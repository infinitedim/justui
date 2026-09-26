// justui-meta: registry=21a17fb617a3462b62e09cb59e44445412eb5832b1d7eabaa607d7fc2b599eca local=a1842eec7c0fef019808ac5ba291243ed0a95d83ea684ff06d62fcfa79e28687
import 'package:flutter/widgets.dart';

import 'just_toggle.dart';
import 'just_toggle_style.dart';
import 'just_toggle_variants.dart';

/// Data model representing an item in the [JustToggleGroup].
class JustToggleGroupItem {
  /// The widget content of the item.
  final Widget child;

  /// Whether this item can be selected.
  final bool enabled;

  /// Creates a [JustToggleGroupItem].
  const JustToggleGroupItem({required this.child, this.enabled = true});
}

/// A group of toggle buttons supporting single or multi-select modes.
/// A group of toggle buttons supporting single or multi-select modes.
class JustToggleGroup extends StatelessWidget {
  /// The list of items in the group.
  final List<JustToggleGroupItem> items;

  /// The set of currently selected indices.
  final Set<int> selectedIndices;

  /// Callback when the set of selected indices changes.
  final ValueChanged<Set<int>>? onChanged;

  /// If false, only one item can be selected (radio behavior).
  final bool allowMultiple;

  /// If false, at least one item must remain selected at all times.
  final bool nullable;

  /// The physical size classification.
  final JustToggleSize size;

  /// Per-instance style overrides.
  final JustToggleStyle? style;

  /// The layout direction of the group.
  final Axis direction;

  const JustToggleGroup({
    super.key,
    required this.items,
    required this.selectedIndices,
    required this.onChanged,
    this.allowMultiple = false,
    this.nullable = true,
    this.size = JustToggleSize.md,
    this.style,
    this.direction = Axis.horizontal,
  });

  void _handlePress(int index) {
    if (onChanged == null) return;

    final Set<int> newSelected = Set<int>.from(selectedIndices);
    final bool isSelected = newSelected.contains(index);

    if (allowMultiple) {
      if (isSelected) {
        if (nullable || newSelected.length > 1) {
          newSelected.remove(index);
        }
      } else {
        newSelected.add(index);
      }
    } else {
      if (isSelected) {
        if (nullable) {
          newSelected.clear();
        }
      } else {
        newSelected.clear();
        newSelected.add(index);
      }
    }

    onChanged!(newSelected);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = List<Widget>.generate(items.length, (
      int index,
    ) {
      final JustToggleGroupItem item = items[index];

      return JustToggleGroupInfo(
        index: index,
        totalCount: items.length,
        direction: direction,
        child: JustToggle(
          selected: selectedIndices.contains(index),
          onPressed: item.enabled ? () => _handlePress(index) : null,
          enabled: item.enabled,
          size: size,
          style: style,
          child: item.child,
        ),
      );
    });

    if (direction == Axis.horizontal) {
      return Row(mainAxisSize: .min, children: children);
    } else {
      return Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: children,
      );
    }
  }
}

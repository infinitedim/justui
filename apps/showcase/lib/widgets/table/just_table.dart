// justui-meta: registry=ee2975495e1aea051e3f3983210c29d78835087736cd8f7bf38bb76e67c2d0b4 local=ca26bd08ea2599f3cc74b6b17d9161059f89c3e44f24cb9a87b69e146e765dc5
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import 'package:showcase/core/just_ui_core.dart';

import '../shared/just_focus_indicator.dart';
import '../shared/just_pressable.dart';
import 'just_table_style.dart';
import 'just_table_theme.dart';
import 'just_table_variants.dart';

/// Data model representing a column definition in the [JustTable].
class const JustTableColumn<T>({
  required final String header,
  required final Widget Function(T row) cell,
  final double? width,
  final bool sortable = false,
  final MainAxisAlignment alignment = .start,
}) {}

/// A premium, customizable data table component built from scratch without Material's [DataTable].
class const JustTable<T>({
  super.key,
  required final List<JustTableColumn<T>> columns,
  required final List<T> rows,
  final bool selectable = false,
  final Set<int>? selectedRows,
  final ValueChanged<Set<int>>? onSelectionChanged,
  final int? sortColumnIndex,
  final bool sortAscending = true,
  final ValueChanged<int>? onSort,
  final bool stickyHeader = true,
  final double rowHeight = 52.0,
  final JustTableVariant variant = JustTableVariant.default_,
  final JustTableStyle? style,
  final Widget? emptyState,
}) extends StatefulWidget {
  @override
  State<JustTable<T>> createState() => _JustTableState<T>();
}

class _JustTableState<T> extends State<JustTable<T>> {
  late Set<int> _internalSelectedRows;

  @override
  void initState() {
    super.initState();
    _internalSelectedRows = Set<int>.from(widget.selectedRows ?? {});
  }

  @override
  void didUpdateWidget(covariant JustTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRows != null) {
      _internalSelectedRows = Set<int>.from(widget.selectedRows!);
    }
  }

  void _toggleSelectAll() {
    if (widget.onSelectionChanged == null) return;

    final newSelection = Set<int>.from(_internalSelectedRows);
    if (newSelection.length == widget.rows.length) {
      newSelection.clear();
    } else {
      newSelection.clear();
      for (int i = 0; i < widget.rows.length; i++) {
        newSelection.add(i);
      }
    }

    if (widget.selectedRows == null) {
      setState(() {
        _internalSelectedRows = newSelection;
      });
    }
    widget.onSelectionChanged!(newSelection);
  }

  void _toggleRow(int index) {
    if (widget.onSelectionChanged == null) return;

    final newSelection = Set<int>.from(_internalSelectedRows);
    if (newSelection.contains(index)) {
      newSelection.remove(index);
    } else {
      newSelection.add(index);
    }

    if (widget.selectedRows == null) {
      setState(() {
        _internalSelectedRows = newSelection;
      });
    }
    widget.onSelectionChanged!(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = JustThemeProvider.of(context).theme;
    final tableTheme = Theme.of(context).extension<JustTableTheme>();
    final themeStyle = tableTheme?.style;

    final colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
    final spacing = JustThemeProvider.of(
      context,
      aspect: .spacing,
    ).theme.spacing;
    final radius = customTheme.radius;
    final typography = JustThemeProvider.of(
      context,
      aspect: .typography,
    ).theme.typography;
    final presetTokens = customTheme.presetTokens;

    // Resolve Styles
    final headerBg =
        widget.style?.headerBackgroundColor ??
        themeStyle?.headerBackgroundColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault.withValues(alpha: 0.1));

    final headerText =
        widget.style?.headerTextColor ??
        themeStyle?.headerTextColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textInverse
            : colors.textPrimary);

    final rowBg =
        widget.style?.rowBackgroundColor ??
        themeStyle?.rowBackgroundColor ??
        colors.background;

    final alternateRowBg =
        widget.style?.alternateRowBackgroundColor ??
        themeStyle?.alternateRowBackgroundColor ??
        colors.borderDefault.withValues(alpha: 0.04);

    final borderColor =
        widget.style?.borderColor ??
        themeStyle?.borderColor ??
        (presetTokens.showsDefaultBorder
            ? colors.textPrimary
            : colors.borderDefault);

    final hoverBg =
        widget.style?.hoverColor ??
        themeStyle?.hoverColor ??
        colors.borderDefault.withValues(alpha: 0.08);

    final selectedBg =
        widget.style?.selectedRowColor ??
        themeStyle?.selectedRowColor ??
        colors.borderFocus.withValues(alpha: 0.15);

    final cellPadding =
        widget.style?.horizontalPadding ??
        themeStyle?.horizontalPadding ??
        spacing.md;

    final headerTextStyle =
        widget.style?.headerTextStyle ??
        themeStyle?.headerTextStyle ??
        typography.bodyMd.copyWith(fontWeight: .w700, color: headerText);

    final cellTextStyle =
        widget.style?.cellTextStyle ??
        themeStyle?.cellTextStyle ??
        typography.bodySm.copyWith(color: colors.textPrimary);

    final BorderRadius defaultBorderRadius = presetTokens.resolveBorderRadius(
      radius,
    );
    final finalRadius = defaultBorderRadius;

    // Outer Container Border
    final tableDecoration = BoxDecoration(
      border: .all(color: borderColor, width: presetTokens.borderWidth),
      borderRadius: finalRadius,
    );

    // Build Column Widgets

    Widget buildCell(
      Widget content,
      double? width,
      MainAxisAlignment alignment, {
      bool isHeader = false,
    }) {
      final Widget cellChild = Container(
        height: isHeader ? 44.0 : widget.rowHeight,
        padding: .symmetric(horizontal: cellPadding),
        alignment: alignment == .start
            ? .centerLeft
            : (alignment == .end ? .centerRight : .center),
        child: content,
      );

      if (width != null) {
        return SizedBox(width: width, child: cellChild);
      } else {
        return Expanded(child: cellChild);
      }
    }

    // Header Row
    final List<Widget> headerCells = [];

    // Optional Checkbox Column
    if (widget.selectable) {
      final isAllSelected =
          widget.rows.isNotEmpty &&
          _internalSelectedRows.length == widget.rows.length;
      headerCells.add(
        buildCell(
          _CustomCheckbox(
            value: isAllSelected,
            onChanged: (_) => _toggleSelectAll(),
            presetTokens: presetTokens,
            colors: colors,
          ),
          48.0,
          .center,
          isHeader: true,
        ),
      );
    }

    for (int i = 0; i < widget.columns.length; i++) {
      final col = widget.columns[i];
      final isSorted = widget.sortColumnIndex == i;

      Widget headerContent = Row(
        mainAxisSize: .min,
        children: [
          Flexible(
            child: Text(
              col.header,
              style: headerTextStyle,
              overflow: .ellipsis,
            ),
          ),
          if (col.sortable) ...[
            SizedBox(width: spacing.xs),
            Icon(
              isSorted
                  ? (widget.sortAscending
                        ? const IconData(0xe5c7, fontFamily: 'MaterialIcons')
                        : const IconData(0xe5c5, fontFamily: 'MaterialIcons'))
                  : const IconData(0xe5d2, fontFamily: 'MaterialIcons'),
              size: 16,
              color: isSorted ? headerText : headerText.withValues(alpha: 0.4),
            ),
          ],
        ],
      );

      if (col.sortable && widget.onSort != null) {
        headerContent = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onSort!(i),
          child: headerContent,
        );
      }

      headerCells.add(
        buildCell(headerContent, col.width, col.alignment, isHeader: true),
      );
    }

    final Widget headerRow = Container(
      color: headerBg,
      child: Row(children: headerCells),
    );

    // Body Rows
    Widget bodyContent;

    if (widget.rows.isEmpty) {
      bodyContent =
          widget.emptyState ??
          Container(
            height: 150,
            alignment: .center,
            child: Text(
              'No data available',
              style: typography.bodyMd.copyWith(color: colors.textSecondary),
            ),
          );
    } else {
      bodyContent = ListView.builder(
        shrinkWrap: true,
        // Every row is built at a fixed widget.rowHeight (see buildCell
        // above), so itemExtent lets the sliver layout compute the list's
        // total scroll extent as `itemCount * rowHeight` without needing to
        // build every row first. Without this, a shrink-wrapped list nested
        // in an unbounded ancestor (the stickyHeader: false path below) has
        // no other way to size itself and must eagerly build every row,
        // which can freeze the UI thread for large datasets.
        itemExtent: widget.rowHeight,
        physics: widget.stickyHeader
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: widget.rows.length,
        itemBuilder: (context, rowIndex) {
          final rowData = widget.rows[rowIndex];
          final isSelected = _internalSelectedRows.contains(rowIndex);
          final isAlternate =
              widget.variant == JustTableVariant.striped && rowIndex.isOdd;

          final List<Widget> rowCells = [];

          // Optional Checkbox Cell
          if (widget.selectable) {
            rowCells.add(
              buildCell(
                _CustomCheckbox(
                  value: isSelected,
                  onChanged: (_) => _toggleRow(rowIndex),
                  presetTokens: presetTokens,
                  colors: colors,
                ),
                48.0,
                .center,
              ),
            );
          }

          // Render Cells
          for (int i = 0; i < widget.columns.length; i++) {
            final col = widget.columns[i];
            rowCells.add(
              buildCell(
                DefaultTextStyle.merge(
                  style: cellTextStyle,
                  child: col.cell(rowData),
                ),
                col.width,
                col.alignment,
              ),
            );
          }

          final Color currentBg = isSelected
              ? selectedBg
              : (isAlternate ? alternateRowBg : rowBg);

          final Widget rowWidget = JustPressable(
            onTap: widget.selectable ? () => _toggleRow(rowIndex) : () {},
            builder: (BuildContext context, JustInteractionState state) {
              final isHovered = state.isHovered;
              Color finalRowBg = currentBg;
              if (isHovered) {
                finalRowBg = isSelected
                    ? selectedBg.withValues(alpha: 0.9)
                    : hoverBg;
              }

              return Container(
                decoration: BoxDecoration(
                  color: finalRowBg,
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor,
                      width: presetTokens.showsDefaultBorder ? 1.0 : 0.5,
                    ),
                    left: presetTokens.showsDefaultBorder && isSelected
                        ? BorderSide(color: colors.borderFocus, width: 3.0)
                        : BorderSide.none,
                  ),
                ),
                child: Row(children: rowCells),
              );
            },
          );

          return rowWidget;
        },
      );
    }

    Widget tableContent;

    if (widget.stickyHeader) {
      tableContent = Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          headerRow,
          Container(height: presetTokens.borderWidth, color: borderColor),
          Flexible(child: SingleChildScrollView(child: bodyContent)),
        ],
      );
    } else {
      tableContent = SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            headerRow,
            Container(height: presetTokens.borderWidth, color: borderColor),
            bodyContent,
          ],
        ),
      );
    }

    // Support horizontal scrolling if table is wider than the viewport
    return Semantics(
      container: true,
      label:
          'Data table with ${widget.columns.length} columns and ${widget.rows.length} rows',
      child: Container(
        decoration: tableDecoration,
        clipBehavior: .antiAlias,
        child: SingleChildScrollView(
          scrollDirection: .horizontal,
          child: SizedBox(
            // Estimate total table width
            width: _estimateTableWidth(widget.columns, widget.selectable),
            child: tableContent,
          ),
        ),
      ),
    );
  }

  double _estimateTableWidth(
    List<JustTableColumn<T>> columns,
    bool selectable,
  ) {
    double totalWidth = selectable ? 48.0 : 0.0;

    for (final col in columns) {
      if (col.width != null) {
        totalWidth += col.width!;
      } else {
        totalWidth += 120.0; // Estimate minimum flex column width
      }
    }

    return totalWidth;
  }
}

/// A lightweight, custom checkbox widget to avoid using Material's [Checkbox].
/// A lightweight, custom checkbox widget to avoid using Material's [Checkbox].
class const _CustomCheckbox({
  required final bool value,
  required final ValueChanged<bool?> onChanged,
  required final JustPresetTokens presetTokens,
  required final JustColorScheme colors,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JustPressable(
      onTap: () => onChanged(!value),
      builder: (BuildContext context, JustInteractionState state) {
        final borderSize = presetTokens.borderWidth;

        final Widget box = Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: value
                ? (presetTokens.showsDefaultBorder
                      ? colors.textPrimary
                      : colors.borderFocus)
                : colors.background,
            border: .all(
              color: presetTokens.showsDefaultBorder
                  ? colors.textPrimary
                  : (value ? colors.borderFocus : colors.borderDefault),
              width: borderSize,
            ),
            borderRadius: presetTokens.showsDefaultBorder
                ? .zero
                : const .all(.circular(4)),
          ),
          alignment: .center,
          child: value
              ? Icon(
                  const IconData(0xe156, fontFamily: 'MaterialIcons'),
                  size: 14,
                  color: colors.textInverse,
                )
              : null,
        );

        return FocusIndicator(
          isFocused: state.isFocusVisible,
          borderRadius: presetTokens.showsDefaultBorder
              ? .zero
              : const .all(.circular(4)),
          child: box,
        );
      },
    );
  }
}

import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';
import 'package:just_ui_tokens/just_ui_tokens.dart';
import '../../shared/default/_shared_theme_provider.dart';
import '../shared/_shared_focus_indicator.dart';
import '../shared/_shared_pressable.dart';
import 'just_table_style.dart';
import 'just_table_theme.dart';
import 'just_table_variants.dart';

/// Data model representing a column definition in the [JustTable].
class JustTableColumn<T> {
  /// The header text displayed at the top of the column.
  final String header;

  /// A builder function to render the cell widget for a given row.
  final Widget Function(T row) cell;

  /// Optional fixed width for the column. If null, the column flexes.
  final double? width;

  /// Whether this column can be sorted by tapping its header.
  final bool sortable;

  /// Alignment of the content within the column. Defaults to [MainAxisAlignment.start].
  final MainAxisAlignment alignment;

  /// Creates a [JustTableColumn].
  const JustTableColumn({
    required this.header,
    required this.cell,
    this.width,
    this.sortable = false,
    this.alignment = MainAxisAlignment.start,
  });
}

/// A premium, customizable data table component built from scratch without Material's [DataTable].
class JustTable<T> extends StatefulWidget {
  /// The column definitions.
  final List<JustTableColumn<T>> columns;

  /// The list of data rows.
  final List<T> rows;

  /// Whether to enable row selection checkboxes.
  final bool selectable;

  /// The set of currently selected row indices.
  final Set<int>? selectedRows;

  /// Callback when the set of selected row indices changes.
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// The index of the column that is currently sorted.
  final int? sortColumnIndex;

  /// Whether the sorted column is in ascending order.
  final bool sortAscending;

  /// Callback when a column header is tapped for sorting.
  final ValueChanged<int>? onSort;

  /// Whether the header row remains fixed at the top while scrolling vertically.
  final bool stickyHeader;

  /// The height of each row. Defaults to 52px.
  final double rowHeight;

  /// The visual variant.
  final JustTableVariant variant;

  /// Per-instance style overrides.
  final JustTableStyle? style;

  /// Widget displayed in the center of the table when [rows] is empty.
  final Widget? emptyState;

  /// Creates a [JustTable] component.
  const JustTable({
    super.key,
    required this.columns,
    required this.rows,
    this.selectable = false,
    this.selectedRows,
    this.onSelectionChanged,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.stickyHeader = true,
    this.rowHeight = 52.0,
    this.variant = JustTableVariant.default_,
    this.style,
    this.emptyState,
  });

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
    final isNeobrutalism = true;

    // Resolve Styles
    final headerBg =
        widget.style?.headerBackgroundColor ??
        themeStyle?.headerBackgroundColor ??
        (isNeobrutalism
            ? colors.textPrimary
            : colors.borderDefault.withValues(alpha: 0.1));

    final headerText =
        widget.style?.headerTextColor ??
        themeStyle?.headerTextColor ??
        (isNeobrutalism ? colors.textInverse : colors.textPrimary);

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
        (isNeobrutalism ? colors.textPrimary : colors.borderDefault);

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

    final BorderRadius defaultBorderRadius = isNeobrutalism
        ? BorderRadius.zero
        : .all(radius.md);
    final finalRadius = defaultBorderRadius;

    // Outer Container Border
    final tableDecoration = BoxDecoration(
      border: Border.all(color: borderColor, width: isNeobrutalism ? 2.5 : 1.0),
      borderRadius: finalRadius,
    );

    // Build Column Widgets
    final int columnCount = widget.columns.length + (widget.selectable ? 1 : 0);

    Widget buildCell(
      Widget content,
      double? width,
      MainAxisAlignment alignment, {
      bool isHeader = false,
    }) {
      Widget cellChild = Container(
        height: isHeader ? 44.0 : widget.rowHeight,
        padding: .symmetric(horizontal: cellPadding),
        alignment: alignment == MainAxisAlignment.start
            ? Alignment.centerLeft
            : (alignment == MainAxisAlignment.end
                  ? Alignment.centerRight
                  : Alignment.center),
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
            isNeobrutalism: isNeobrutalism,
            colors: colors,
          ),
          48.0,
          MainAxisAlignment.center,
          isHeader: true,
        ),
      );
    }

    for (int i = 0; i < widget.columns.length; i++) {
      final col = widget.columns[i];
      final isSorted = widget.sortColumnIndex == i;

      Widget headerContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              col.header,
              style: headerTextStyle,
              overflow: TextOverflow.ellipsis,
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

    Widget headerRow = Container(
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
            alignment: Alignment.center,
            child: Text(
              'No data available',
              style: typography.bodyMd.copyWith(color: colors.textSecondary),
            ),
          );
    } else {
      bodyContent = ListView.builder(
        shrinkWrap: true,
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
                  isNeobrutalism: isNeobrutalism,
                  colors: colors,
                ),
                48.0,
                MainAxisAlignment.center,
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

          Color currentBg = isSelected
              ? selectedBg
              : (isAlternate ? alternateRowBg : rowBg);

          Widget rowWidget = JustPressable(
            onTap: widget.selectable ? () => _toggleRow(rowIndex) : () {},
            builder: (context, isHovered, isPressed, _, __) {
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
                      width: isNeobrutalism ? 1.0 : 0.5,
                    ),
                    left: isNeobrutalism && isSelected
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          headerRow,
          Container(height: isNeobrutalism ? 2.5 : 1.0, color: borderColor),
          Flexible(child: SingleChildScrollView(child: bodyContent)),
        ],
      );
    } else {
      tableContent = SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            headerRow,
            Container(height: isNeobrutalism ? 2.5 : 1.0, color: borderColor),
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
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
    bool hasFlex = false;

    for (final col in columns) {
      if (col.width != null) {
        totalWidth += col.width!;
      } else {
        hasFlex = true;
        totalWidth += 120.0; // Estimate minimum flex column width
      }
    }

    return totalWidth;
  }
}

/// A lightweight, custom checkbox widget to avoid using Material's [Checkbox].
class _CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isNeobrutalism;
  final JustColorScheme colors;

  const _CustomCheckbox({
    required this.value,
    required this.onChanged,
    required this.isNeobrutalism,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return JustPressable(
      onTap: () => onChanged(!value),
      builder: (context, isHovered, isPressed, isFocused, _) {
        final borderSize = isNeobrutalism ? 2.5 : 1.5;

        Widget box = Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: value
                ? (isNeobrutalism ? colors.textPrimary : colors.borderFocus)
                : colors.background,
            border: Border.all(
              color: isNeobrutalism
                  ? colors.textPrimary
                  : (value ? colors.borderFocus : colors.borderDefault),
              width: borderSize,
            ),
            borderRadius: isNeobrutalism
                ? BorderRadius.zero
                : const BorderRadius.all(Radius.circular(4)),
          ),
          alignment: Alignment.center,
          child: value
              ? Icon(
                  const IconData(0xe156, fontFamily: 'MaterialIcons'),
                  size: 14,
                  color: colors.textInverse,
                )
              : null,
        );

        return FocusIndicator(
          isFocused: isFocused,
          focusColor: colors.borderFocus,
          borderRadius: isNeobrutalism
              ? BorderRadius.zero
              : const BorderRadius.all(Radius.circular(4)),
          child: box,
        );
      },
    );
  }
}

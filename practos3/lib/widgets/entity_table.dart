import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final ValueChanged<bool>? onToggleSelectAll;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.onToggleSelectAll,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allSelected =
        items.isNotEmpty && items.every((item) => selected.contains(idOf(item)));

    final dataColumns = <DataColumn>[
      if (onToggleSelect != null)
        DataColumn(
          label: Checkbox(
            value: allSelected,
            tristate: false,
            onChanged: (value) => onToggleSelectAll?.call(value ?? false),
          ),
        ),
      for (final column in columns)
        DataColumn(
          label: Text(column.label),
          numeric: column.numeric,
          onSort: column.sortField == null || onSort == null
              ? null
              : (_, _) => onSort!(column.sortField!),
          columnWidth: const IntrinsicColumnWidth(),
        ),
      if (actions != null) const DataColumn(label: Text('')),
    ];

    final dataRows = [
      for (final item in items)
        DataRow(
          selected: selected.contains(idOf(item)),
          onSelectChanged: onToggleSelect == null
              ? null
              : (_) => onToggleSelect!(idOf(item)),
          cells: [
            if (onToggleSelect != null)
              DataCell(
                Checkbox(
                  value: selected.contains(idOf(item)),
                  onChanged: (_) => onToggleSelect!(idOf(item)),
                ),
              ),
            for (final column in columns)
              DataCell(column.build(item)),
            if (actions != null) DataCell(Row(children: actions!(item))),
          ],
        ),
    ];

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            sortColumnIndex:
                sortField == null ? null : _sortColumnIndex(sortField!),
            sortAscending: sortAscending,
            showCheckboxColumn: false,
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.surfaceContainerHighest,
            ),
            columns: dataColumns,
            rows: dataRows,
          ),
        ),
      ),
    );
  }

  int? _sortColumnIndex(String field) {
    var index = onToggleSelect != null ? 1 : 0;
    for (final column in columns) {
      if (column.sortField == field) return index;
      index++;
    }
    return null;
  }
}

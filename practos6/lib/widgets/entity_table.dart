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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return _buildCards(context, constraints.maxWidth);
        }
        return _buildTable(context);
      },
    );
  }

  Widget _buildCards(BuildContext context, double maxWidth) {
    final columnsCount = maxWidth >= 600 ? 2 : 1;
    final gap = 12.0;
    final cardWidth = (maxWidth - gap * (columnsCount - 1)) / columnsCount;

    return SingleChildScrollView(
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final item in items)
            SizedBox(
              width: cardWidth,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (onToggleSelect != null)
                            Checkbox(
                              value: selected.contains(idOf(item)),
                              onChanged: (_) => onToggleSelect!(idOf(item)),
                            ),
                          Expanded(child: columns.first.build(item)),
                          if (actions != null) Wrap(children: actions!(item)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final column in columns.skip(1))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(
                                  column.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9AA0A6),
                                  ),
                                ),
                              ),
                              Expanded(child: column.build(item)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final theme = Theme.of(context);

    final dataColumns = <DataColumn>[
      if (onToggleSelect != null)
        DataColumn(
          label: Checkbox(
            value:
                items.isNotEmpty &&
                items.every((item) => selected.contains(idOf(item))),
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

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            sortColumnIndex: sortField == null
                ? null
                : _sortColumnIndex(sortField!),
            sortAscending: sortAscending,
            showCheckboxColumn: false,
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.surfaceContainerHigh,
            ),
            columns: dataColumns,
            rows: _dataRows(),
          ),
        ),
      ),
    );
  }

  List<DataRow> _dataRows() {
    return [
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
            for (final column in columns) DataCell(column.build(item)),
            if (actions != null) DataCell(Row(children: actions!(item))),
          ],
        ),
    ];
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

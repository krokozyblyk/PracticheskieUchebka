import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practos2/widgets/entity_table.dart';

void main() {
  testWidgets('сортировка по колонке вызывает onSort', (tester) async {
    String? sortedField;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntityTable<String>(
            items: const ['а', 'б'],
            idOf: (s) => s.hashCode,
            sortField: 'name',
            sortAscending: true,
            onSort: (field) => sortedField = field,
            columns: [
              TableColumnSpec(
                label: 'Название',
                sortField: 'name',
                build: (s) => Text(s),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Название'));
    expect(sortedField, 'name');
  });

  testWidgets('чекбоксы переключают выбор', (tester) async {
    final selected = <int>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntityTable<String>(
            items: const ['а', 'б'],
            idOf: (s) => s.hashCode,
            selected: selected,
            onToggleSelect: (id) {
              if (selected.contains(id)) {
                selected.remove(id);
              } else {
                selected.add(id);
              }
            },
            columns: [
              TableColumnSpec(
                label: 'Название',
                build: (s) => Text(s),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(Checkbox), findsNWidgets(3));
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    expect(selected.length, 1);
  });

  testWidgets('выводит строки для всех элементов', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntityTable<int>(
            items: const [1, 2, 3],
            idOf: (i) => i,
            columns: [
              TableColumnSpec(label: 'Значение', build: (i) => Text('$i')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:practos2/repositories/in_memory_category_repository.dart';

void main() {
  late InMemoryCategoryRepository repo;

  setUp(() {
    repo = InMemoryCategoryRepository();
  });

  test('начальный набор содержит не менее 8 категорий', () async {
    final result = await repo.find(
      search: '',
      sortField: 'name',
      sortAscending: true,
      page: 1,
      size: 10,
      includeDeleted: false,
    );
    expect(result.total, greaterThanOrEqualTo(8));
  });

  test('поиск по названию и разделу', () async {
    final result = await repo.find(
      search: 'аква',
      sortField: 'name',
      sortAscending: true,
      page: 1,
      size: 10,
      includeDeleted: false,
    );
    expect(result.items.every((c) =>
        c.name.toLowerCase().contains('аква') ||
        c.section.toLowerCase().contains('аква')), isTrue);
  });

  test('softDelete убирает, restore возвращает', () async {
    await repo.softDelete(1);
    final afterDelete = await repo.find(
      search: '',
      sortField: 'name',
      sortAscending: true,
      page: 1,
      size: 10,
      includeDeleted: false,
    );
    expect(afterDelete.items.any((c) => c.id == 1), isFalse);

    await repo.restore(1);
    final afterRestore = await repo.find(
      search: '',
      sortField: 'name',
      sortAscending: true,
      page: 1,
      size: 10,
      includeDeleted: false,
    );
    expect(afterRestore.items.any((c) => c.id == 1), isTrue);
  });

  test('hardDelete удаляет насовсем', () async {
    await repo.hardDelete(1);
    final result = await repo.find(
      search: '',
      sortField: 'name',
      sortAscending: true,
      page: 1,
      size: 10,
      includeDeleted: true,
    );
    expect(result.items.any((c) => c.id == 1), isFalse);
  });
}

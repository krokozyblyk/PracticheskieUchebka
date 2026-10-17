import 'package:flutter_test/flutter_test.dart';
import 'package:practos2/models/animal_query.dart';
import 'package:practos2/repositories/in_memory_animal_repository.dart';

void main() {
  late InMemoryAnimalRepository repo;

  setUp(() {
    repo = InMemoryAnimalRepository();
  });

  test('начальный набор содержит не менее 20 животных', () async {
    final result = await repo.find(const AnimalQuery());
    expect(result.total, greaterThanOrEqualTo(20));
  });

  test('поиск по названию и виду', () async {
    final result =
        await repo.find(const AnimalQuery(search: 'кот'));
    expect(result.items.every((a) =>
        a.name.toLowerCase().contains('кот') ||
        a.species.toLowerCase().contains('кот')), isTrue);
    expect(result.items, isNotEmpty);
  });

  test('фильтр по категории, поставщику и цене комбинируются', () async {
    final result = await repo.find(const AnimalQuery(
      categoryId: 2,
      supplierId: 1,
      priceFrom: 1000,
      priceTo: 20000,
    ));
    for (final a in result.items) {
      expect(a.categoryIds, contains(2));
      expect(a.supplierId, 1);
      expect(a.price, inInclusiveRange(1000, 20000));
    }
  });

  test('сортировка по цене по возрастанию', () async {
    final result =
        await repo.find(const AnimalQuery(sortField: 'price', sortAscending: true));
    final prices = result.items.map((a) => a.price).toList();
    final sorted = [...prices]..sort();
    expect(prices, sorted);
  });

  test('сортировка по цене по убыванию', () async {
    final result = await repo.find(
        const AnimalQuery(sortField: 'price', sortAscending: false));
    final prices = result.items.map((a) => a.price).toList();
    final sorted = [...prices]..sort((a, b) => b.compareTo(a));
    expect(prices, sorted);
  });

  test('пагинация: вторая страница не пересекается с первой', () async {
    final page1 = await repo.find(const AnimalQuery(page: 1, size: 10));
    final page2 = await repo.find(const AnimalQuery(page: 2, size: 10));
    final ids1 = page1.items.map((a) => a.id).toSet();
    final ids2 = page2.items.map((a) => a.id).toSet();
    expect(ids1.intersection(ids2), isEmpty);
  });

  test('softDelete убирает из выборки, restore возвращает', () async {
    await repo.softDelete(1);
    final afterDelete = await repo.find(const AnimalQuery());
    expect(afterDelete.items.any((a) => a.id == 1), isFalse);

    await repo.restore(1);
    final afterRestore = await repo.find(const AnimalQuery());
    expect(afterRestore.items.any((a) => a.id == 1), isTrue);
  });

  test('includeDeleted показывает удалённые', () async {
    await repo.softDelete(1);
    final result = await repo.find(const AnimalQuery(includeDeleted: true));
    expect(result.items.any((a) => a.id == 1), isTrue);
  });

  test('hardDelete удаляет насовсем', () async {
    await repo.hardDelete(1);
    final result =
        await repo.find(const AnimalQuery(includeDeleted: true));
    expect(result.items.any((a) => a.id == 1), isFalse);
  });

  test('deleteMany считает и удаляет несколько', () async {
    final count = await repo.deleteMany([1, 2, 3, 999]);
    expect(count, 3);
    final result = await repo.find(const AnimalQuery());
    expect(result.items.any((a) => a.id == 1), isFalse);
    expect(result.items.any((a) => a.id == 2), isFalse);
    expect(result.items.any((a) => a.id == 3), isFalse);
  });

  test('findById находит и возвращает null для несуществующего', () async {
    expect(await repo.findById(1), isNotNull);
    expect(await repo.findById(99999), isNull);
  });
}

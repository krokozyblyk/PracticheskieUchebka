import '../models/animal.dart';
import '../models/page_result.dart';
import '../models/animal_query.dart';
import 'animal_repository.dart';

class InMemoryAnimalRepository implements AnimalRepository {
  final List<Animal> _animals = [...seedAnimals];
  int _nextId = seedAnimals.length + 1;

  @override
  Future<PageResult<Animal>> find(AnimalQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _animals.where((a) => q.includeDeleted || !a.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((a) =>
              a.name.toLowerCase().contains(needle) ||
              a.species.toLowerCase().contains(needle))
          .toList();
    }
    if (q.categoryId != null) {
      rows = rows.where((a) => a.categoryIds.contains(q.categoryId)).toList();
    }
    if (q.supplierId != null) {
      rows = rows.where((a) => a.supplierId == q.supplierId).toList();
    }
    if (q.priceFrom != null) {
      rows = rows.where((a) => a.price >= q.priceFrom!).toList();
    }
    if (q.priceTo != null) {
      rows = rows.where((a) => a.price <= q.priceTo!).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'price' => a.price.compareTo(b.price),
        'age' => a.age.compareTo(b.age),
        'quantity' => a.quantity.compareTo(b.quantity),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Animal>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Animal?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final a in _animals) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<Animal> create(Animal animal) async {
    final created = Animal(
      id: _nextId++,
      name: animal.name,
      species: animal.species,
      age: animal.age,
      price: animal.price,
      supplierId: animal.supplierId,
      categoryIds: animal.categoryIds,
      quantity: animal.quantity,
      deletedAt: animal.deletedAt,
    );
    _animals.add(created);
    return created;
  }

  @override
  Future<Animal> update(Animal animal) async {
    final i = _animals.indexWhere((a) => a.id == animal.id);
    if (i == -1) throw StateError('Животное ${animal.id} не найдено');
    _animals[i] = animal;
    return animal;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _animals.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Животное $id не найдено');
    _animals[i] = _animals[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _animals.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _animals.indexWhere((a) => a.id == id);
    if (i == -1) throw StateError('Животное $id не найдено');
    _animals[i] = _animals[i].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _animals.indexWhere((a) => a.id == id && !a.isDeleted);
      if (i != -1) {
        _animals[i] = _animals[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}

const List<Animal> seedAnimals = [
  Animal(id: 1, name: 'Барсик', species: 'Кот', age: 2, price: 5000, supplierId: 1, categoryIds: [1], quantity: 4),
  Animal(id: 2, name: 'Мурка', species: 'Кошка', age: 3, price: 4500, supplierId: 2, categoryIds: [1], quantity: 2),
  Animal(id: 3, name: 'Рекс', species: 'Собака', age: 1, price: 12000, supplierId: 1, categoryIds: [2], quantity: 3),
  Animal(id: 4, name: 'Бобик', species: 'Собака', age: 4, price: 8000, supplierId: 3, categoryIds: [2], quantity: 1),
  Animal(id: 5, name: 'Кеша', species: 'Попугай', age: 1, price: 2500, supplierId: 4, categoryIds: [3], quantity: 6),
  Animal(id: 6, name: 'Гоша', species: 'Попугай', age: 2, price: 3000, supplierId: 4, categoryIds: [3], quantity: 5),
  Animal(id: 7, name: 'Шарик', species: 'Хомяк', age: 1, price: 500, supplierId: 2, categoryIds: [4], quantity: 10),
  Animal(id: 8, name: 'Пушок', species: 'Кролик', age: 1, price: 1500, supplierId: 3, categoryIds: [4], quantity: 7),
  Animal(id: 9, name: 'Немо', species: 'Рыба', age: 1, price: 300, supplierId: 3, categoryIds: [5], quantity: 20),
  Animal(id: 10, name: 'Дори', species: 'Рыба', age: 1, price: 350, supplierId: 3, categoryIds: [5], quantity: 18),
  Animal(id: 11, name: 'Тоша', species: 'Черепаха', age: 5, price: 2000, supplierId: 1, categoryIds: [6], quantity: 2),
  Animal(id: 12, name: 'Кузя', species: 'Ящерица', age: 2, price: 3500, supplierId: 4, categoryIds: [6], quantity: 3),
  Animal(id: 13, name: 'Снежок', species: 'Кошка', age: 1, price: 5500, supplierId: 2, categoryIds: [1], quantity: 4),
  Animal(id: 14, name: 'Граф', species: 'Собака', age: 3, price: 15000, supplierId: 1, categoryIds: [2], quantity: 2),
  Animal(id: 15, name: 'Чип', species: 'Морская свинка', age: 1, price: 1200, supplierId: 2, categoryIds: [4], quantity: 9),
  Animal(id: 16, name: 'Дейл', species: 'Морская свинка', age: 1, price: 1200, supplierId: 2, categoryIds: [4], quantity: 8),
  Animal(id: 17, name: 'Ара', species: 'Попугай', age: 4, price: 8000, supplierId: 4, categoryIds: [3], quantity: 1),
  Animal(id: 18, name: 'Злата', species: 'Рыба', age: 1, price: 600, supplierId: 3, categoryIds: [5], quantity: 12),
  Animal(id: 19, name: 'Барон', species: 'Хомяк', age: 2, price: 450, supplierId: 1, categoryIds: [4], quantity: 11),
  Animal(id: 20, name: 'Лаки', species: 'Собака', age: 2, price: 11000, supplierId: 2, categoryIds: [2], quantity: 3),
];

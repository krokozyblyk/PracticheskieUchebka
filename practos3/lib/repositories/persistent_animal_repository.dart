import 'package:shared_preferences/shared_preferences.dart';

import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/page_result.dart';
import 'animal_repository.dart';
import 'persistent_store.dart';

class PersistentAnimalRepository implements AnimalRepository {
  PersistentAnimalRepository(SharedPreferences prefs)
      : _store = PersistentStore<Animal>(
          prefs: prefs,
          key: 'animals_v1',
          fromJson: Animal.fromJson,
          toJson: (animal) => animal.toJson(),
          seed: () => seedAnimals,
        );

  final PersistentStore<Animal> _store;

  List<Animal> get _animals => _store.items;

  Future<void> _save() => _store.persist();

  @override
  Future<PageResult<Animal>> find(AnimalQuery q) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var rows = _animals.where((a) => q.includeDeleted || !a.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((a) =>
              a.name.toLowerCase().contains(needle) ||
              a.species.toLowerCase().contains(needle) ||
              a.sku.toLowerCase().contains(needle))
          .toList();
    }
    if (q.categoryId != null) {
      rows = rows.where((a) => a.categoryIds.contains(q.categoryId)).toList();
    }
    if (q.supplierId != null) {
      rows = rows.where((a) => a.supplierId == q.supplierId).toList();
    }
    if (q.vetId != null) {
      rows = rows.where((a) => a.vetIds.contains(q.vetId)).toList();
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
        'sku' => a.sku.toLowerCase().compareTo(b.sku.toLowerCase()),
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
    for (final animal in _animals) {
      if (animal.id == id) return animal;
    }
    return null;
  }

  @override
  Future<Animal> create(Animal animal) async {
    final nextId = _animals.fold<int>(
          0,
          (max, current) => current.id > max ? current.id : max,
        ) +
        1;
    final created = _copy(animal, id: nextId);
    _animals.add(created);
    await _save();
    return created;
  }

  @override
  Future<Animal> update(Animal animal) async {
    final index = _animals.indexWhere((a) => a.id == animal.id);
    if (index == -1) throw StateError('Животное ${animal.id} не найдено');
    _animals[index] = animal;
    await _save();
    return animal;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _animals.indexWhere((a) => a.id == id);
    if (index == -1) throw StateError('Животное $id не найдено');
    _animals[index] = _animals[index].copyWith(deletedAt: DateTime.now());
    await _save();
  }

  @override
  Future<void> hardDelete(int id) async {
    _animals.removeWhere((a) => a.id == id);
    await _save();
  }

  @override
  Future<void> restore(int id) async {
    final index = _animals.indexWhere((a) => a.id == id);
    if (index == -1) throw StateError('Животное $id не найдено');
    _animals[index] = _animals[index].copyWith(clearDeletedAt: true);
    await _save();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (var i = 0; i < _animals.length; i++) {
      if (ids.contains(_animals[i].id) && !_animals[i].isDeleted) {
        _animals[i] = _animals[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    if (count > 0) await _save();
    return count;
  }

  @override
  Future<int> hardDeleteMany(List<int> ids) async {
    final before = _animals.length;
    _animals.removeWhere((a) => ids.contains(a.id));
    final count = before - _animals.length;
    if (count > 0) await _save();
    return count;
  }

  @override
  Future<int> restoreMany(List<int> ids) async {
    var count = 0;
    for (var i = 0; i < _animals.length; i++) {
      if (ids.contains(_animals[i].id) && _animals[i].isDeleted) {
        _animals[i] = _animals[i].copyWith(clearDeletedAt: true);
        count++;
      }
    }
    if (count > 0) await _save();
    return count;
  }

  @override
  Future<bool> existsSku(String sku, {int? exceptId}) async {
    final needle = sku.trim().toLowerCase();
    if (needle.isEmpty) return false;
    return _animals.any((a) =>
        a.sku.trim().toLowerCase() == needle && a.id != exceptId);
  }

  @override
  Future<int> countBySupplier(int supplierId) async {
    return _animals.where((a) => a.supplierId == supplierId).length;
  }

  Animal _copy(Animal animal, {required int id}) => Animal(
        id: id,
        name: animal.name,
        species: animal.species,
        sku: animal.sku,
        age: animal.age,
        price: animal.price,
        supplierId: animal.supplierId,
        categoryIds: animal.categoryIds,
        vetIds: animal.vetIds,
        quantity: animal.quantity,
        description: animal.description,
        deletedAt: animal.deletedAt,
      );
}

const List<Animal> seedAnimals = [
  Animal(id: 1, name: 'Барсик', species: 'Кот', sku: 'AN-001', age: 2, price: 5000, supplierId: 1, categoryIds: [1], vetIds: [1], quantity: 4),
  Animal(id: 2, name: 'Мурка', species: 'Кошка', sku: 'AN-002', age: 3, price: 4500, supplierId: 2, categoryIds: [1], vetIds: [1], quantity: 2),
  Animal(id: 3, name: 'Рекс', species: 'Собака', sku: 'AN-003', age: 1, price: 12000, supplierId: 1, categoryIds: [2], vetIds: [2], quantity: 3),
  Animal(id: 4, name: 'Бобик', species: 'Собака', sku: 'AN-004', age: 4, price: 8000, supplierId: 3, categoryIds: [2], vetIds: [2], quantity: 1),
  Animal(id: 5, name: 'Кеша', species: 'Попугай', sku: 'AN-005', age: 1, price: 2500, supplierId: 4, categoryIds: [3], vetIds: [3], quantity: 6),
  Animal(id: 6, name: 'Гоша', species: 'Попугай', sku: 'AN-006', age: 2, price: 3000, supplierId: 4, categoryIds: [3], vetIds: [3], quantity: 5),
  Animal(id: 7, name: 'Шарик', species: 'Хомяк', sku: 'AN-007', age: 1, price: 500, supplierId: 2, categoryIds: [4], vetIds: [4], quantity: 10),
  Animal(id: 8, name: 'Пушок', species: 'Кролик', sku: 'AN-008', age: 1, price: 1500, supplierId: 3, categoryIds: [4], vetIds: [4], quantity: 7),
  Animal(id: 9, name: 'Немо', species: 'Рыба', sku: 'AN-009', age: 1, price: 300, supplierId: 3, categoryIds: [5], vetIds: [5], quantity: 20),
  Animal(id: 10, name: 'Дори', species: 'Рыба', sku: 'AN-010', age: 1, price: 350, supplierId: 3, categoryIds: [5], vetIds: [5], quantity: 18),
  Animal(id: 11, name: 'Тоша', species: 'Черепаха', sku: 'AN-011', age: 5, price: 2000, supplierId: 1, categoryIds: [6], vetIds: [6], quantity: 2),
  Animal(id: 12, name: 'Кузя', species: 'Ящерица', sku: 'AN-012', age: 2, price: 3500, supplierId: 4, categoryIds: [6], vetIds: [6], quantity: 3),
  Animal(id: 13, name: 'Снежок', species: 'Кошка', sku: 'AN-013', age: 1, price: 5500, supplierId: 2, categoryIds: [1], vetIds: [1], quantity: 4),
  Animal(id: 14, name: 'Граф', species: 'Собака', sku: 'AN-014', age: 3, price: 15000, supplierId: 1, categoryIds: [2], vetIds: [2], quantity: 2),
  Animal(id: 15, name: 'Чип', species: 'Морская свинка', sku: 'AN-015', age: 1, price: 1200, supplierId: 2, categoryIds: [4], vetIds: [4], quantity: 9),
  Animal(id: 16, name: 'Дейл', species: 'Морская свинка', sku: 'AN-016', age: 1, price: 1200, supplierId: 2, categoryIds: [4], vetIds: [4], quantity: 8),
  Animal(id: 17, name: 'Ара', species: 'Попугай', sku: 'AN-017', age: 4, price: 8000, supplierId: 4, categoryIds: [3], vetIds: [3], quantity: 1),
  Animal(id: 18, name: 'Злата', species: 'Рыба', sku: 'AN-018', age: 1, price: 600, supplierId: 3, categoryIds: [5], vetIds: [5], quantity: 12),
  Animal(id: 19, name: 'Барон', species: 'Хомяк', sku: 'AN-019', age: 2, price: 450, supplierId: 1, categoryIds: [4], vetIds: [4], quantity: 11),
  Animal(id: 20, name: 'Лаки', species: 'Собака', sku: 'AN-020', age: 2, price: 11000, supplierId: 2, categoryIds: [2], vetIds: [2], quantity: 3),
];

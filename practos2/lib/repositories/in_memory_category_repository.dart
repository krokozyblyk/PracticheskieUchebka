import '../models/category.dart';
import '../models/page_result.dart';
import 'category_repository.dart';

class InMemoryCategoryRepository implements CategoryRepository {
  final List<Category> _categories = [...seedCategories];

  @override
  Future<PageResult<Category>> find({
    required String search,
    required String sortField,
    required bool sortAscending,
    required int page,
    required int size,
    required bool includeDeleted,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows =
        _categories.where((c) => includeDeleted || !c.isDeleted).toList();

    if (search.trim().isNotEmpty) {
      final needle = search.trim().toLowerCase();
      rows = rows
          .where((c) =>
              c.name.toLowerCase().contains(needle) ||
              c.section.toLowerCase().contains(needle))
          .toList();
    }

    rows.sort((a, b) {
      final result = switch (sortField) {
        'section' => a.section.toLowerCase().compareTo(b.section.toLowerCase()),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (page - 1) * size;
    final to = (from + size) > total ? total : (from + size);
    final items = from >= total ? <Category>[] : rows.sublist(from, to);
    return PageResult(items: items, page: page, size: size, total: total);
  }

  @override
  Future<Category?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Категория $id не найдена');
    _categories[i] = _categories[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _categories.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i == -1) throw StateError('Категория $id не найдена');
    _categories[i] = _categories[i].copyWith(clearDeletedAt: true);
  }
}

const List<Category> seedCategories = [
  Category(id: 1, name: 'Кошки', section: 'Домашние'),
  Category(id: 2, name: 'Собаки', section: 'Домашние'),
  Category(id: 3, name: 'Птицы', section: 'Пернатые'),
  Category(id: 4, name: 'Грызуны', section: 'Мелкие'),
  Category(id: 5, name: 'Рыбки', section: 'Аквариум'),
  Category(id: 6, name: 'Рептилии', section: 'Экзотика'),
  Category(id: 7, name: 'Кролики', section: 'Мелкие'),
  Category(id: 8, name: 'Амфибии', section: 'Экзотика'),
];

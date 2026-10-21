import '../models/list_query.dart';
import '../models/page_result.dart';
import 'entity_repository.dart';
import 'persistent_store.dart';

abstract class PersistentEntityRepository<T> implements EntityRepository<T> {
  PersistentEntityRepository(this._store);

  final PersistentStore<T> _store;

  List<T> get items => _store.items;

  int idOf(T item);

  T withId(T item, int id);

  T withDeletedAt(T item, DateTime? deletedAt);

  DateTime? deletedAtOf(T item);

  List<String> searchText(T item);

  String sortText(T item, String field);

  Future<void> save() => _store.persist();

  @override
  Future<PageResult<T>> find(ListQuery query) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var rows = items
        .where((item) => query.includeDeleted || deletedAtOf(item) == null)
        .toList();

    if (query.search.trim().isNotEmpty) {
      final needle = query.search.trim().toLowerCase();
      rows = rows
          .where((item) =>
              searchText(item).any((text) => text.toLowerCase().contains(needle)))
          .toList();
    }

    rows.sort((a, b) {
      final result = sortText(a, query.sortField)
          .toLowerCase()
          .compareTo(sortText(b, query.sortField).toLowerCase());
      return query.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (query.page - 1) * query.size;
    final to = (from + query.size) > total ? total : (from + query.size);
    final pageItems = from >= total ? <T>[] : rows.sublist(from, to);
    return PageResult(
      items: pageItems,
      page: query.page,
      size: query.size,
      total: total,
    );
  }

  @override
  Future<T?> findById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final item in items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  @override
  Future<T> create(T item) async {
    final nextId = items.fold<int>(
          0,
          (max, current) => idOf(current) > max ? idOf(current) : max,
        ) +
        1;
    final created = withId(item, nextId);
    items.add(created);
    await save();
    return created;
  }

  @override
  Future<T> update(T item) async {
    final index = items.indexWhere((current) => idOf(current) == idOf(item));
    if (index == -1) {
      throw StateError('Запись ${idOf(item)} не найдена');
    }
    items[index] = item;
    await save();
    return item;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = items.indexWhere((item) => idOf(item) == id);
    if (index == -1) throw StateError('Запись $id не найдена');
    items[index] = withDeletedAt(items[index], DateTime.now());
    await save();
  }

  @override
  Future<void> hardDelete(int id) async {
    items.removeWhere((item) => idOf(item) == id);
    await save();
  }

  @override
  Future<void> restore(int id) async {
    final index = items.indexWhere((item) => idOf(item) == id);
    if (index == -1) throw StateError('Запись $id не найдена');
    items[index] = withDeletedAt(items[index], null);
    await save();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (var i = 0; i < items.length; i++) {
      if (ids.contains(idOf(items[i])) && deletedAtOf(items[i]) == null) {
        items[i] = withDeletedAt(items[i], DateTime.now());
        count++;
      }
    }
    if (count > 0) await save();
    return count;
  }

  @override
  Future<int> hardDeleteMany(List<int> ids) async {
    final before = items.length;
    items.removeWhere((item) => ids.contains(idOf(item)));
    final count = before - items.length;
    if (count > 0) await save();
    return count;
  }

  @override
  Future<int> restoreMany(List<int> ids) async {
    var count = 0;
    for (var i = 0; i < items.length; i++) {
      if (ids.contains(idOf(items[i])) && deletedAtOf(items[i]) != null) {
        items[i] = withDeletedAt(items[i], null);
        count++;
      }
    }
    if (count > 0) await save();
    return count;
  }
}

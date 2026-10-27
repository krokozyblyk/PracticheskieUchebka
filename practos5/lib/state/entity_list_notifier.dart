import 'package:flutter/foundation.dart';

import '../core/api_exceptions.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import '../repositories/entity_repository.dart';
import 'list_controller.dart';
import 'load_status.dart';

class EntityListNotifier<T> extends ChangeNotifier
    implements PagedListController<T> {
  final EntityRepository<T> _repository;

  EntityListNotifier(this._repository);

  ListQuery _query = const ListQuery();
  PageResult<T> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};
  int _requestId = 0;

  ListQuery get query => _query;

  @override
  PageResult<T> get result => _result;

  @override
  LoadStatus get status => _status;

  @override
  String? get error => _error;

  @override
  Set<int> get selected => Set.unmodifiable(_selected);

  @override
  bool get hasSelection => _selected.isNotEmpty;

  @override
  bool get includeDeleted => _query.includeDeleted;

  @override
  String get search => _query.search;

  @override
  String get sortField => _query.sortField;

  @override
  bool get sortAscending => _query.sortAscending;

  @override
  Future<void> load() async {
    final requestId = ++_requestId;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.find(_query);
      if (requestId != _requestId) return;
      _result = result;
      _status = LoadStatus.success;
    } on RequestCancelledException {
      if (requestId == _requestId) {
        _status = LoadStatus.success;
      }
      return;
    } catch (error) {
      if (requestId != _requestId) return;
      _error = 'Не удалось загрузить список: $error';
      _status = LoadStatus.error;
    } finally {
      if (requestId == _requestId) notifyListeners();
    }
  }

  Future<void> applyQuery(ListQuery next) async {
    if (_query == next) return;
    _query = next;
    _selected.clear();
    await load();
  }

  @override
  Future<void> setSearch(String value) =>
      applyQuery(_query.copyWith(search: value));

  @override
  Future<void> sortBy(String field) => applyQuery(_query.copyWith(
        sortField: field,
        sortAscending: field == _query.sortField ? !_query.sortAscending : true,
      ));

  @override
  Future<void> goToPage(int page) => applyQuery(_query.copyWith(page: page));

  @override
  Future<void> setSize(int size) => applyQuery(_query.copyWith(size: size));

  @override
  Future<void> setIncludeDeleted(bool value) =>
      applyQuery(_query.copyWith(includeDeleted: value));

  @override
  void toggleSelection(int id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
    notifyListeners();
  }

  @override
  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  @override
  Future<void> hardDeleteSelected() async {
    await _repository.hardDeleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  @override
  Future<void> restoreSelected() async {
    await _repository.restoreMany(_selected.toList());
    _selected.clear();
    await load();
  }

  @override
  Future<void> deleteOne(int id) async {
    await _repository.softDelete(id);
    _selected.clear();
    await load();
  }

  @override
  Future<void> hardDeleteOne(int id) async {
    await _repository.hardDelete(id);
    _selected.clear();
    await load();
  }

  @override
  Future<void> restoreOne(int id) async {
    await _repository.restore(id);
    _selected.clear();
    await load();
  }
}

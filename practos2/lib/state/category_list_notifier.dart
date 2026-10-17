import 'package:flutter/foundation.dart';

import '../models/category.dart' as model;
import '../models/page_result.dart';
import '../repositories/category_repository.dart';

enum LoadStatus { idle, loading, success, error }

class CategoryListNotifier extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryListNotifier(this._repository);

  String _search = '';
  String _sortField = 'name';
  bool _sortAscending = true;
  int _page = 1;
  int _size = 10;
  bool _includeDeleted = false;

  PageResult<model.Category> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  String get search => _search;
  String get sortField => _sortField;
  bool get sortAscending => _sortAscending;
  int get page => _page;
  int get size => _size;
  bool get includeDeleted => _includeDeleted;
  PageResult<model.Category> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await _repository.find(
        search: _search,
        sortField: _sortField,
        sortAscending: _sortAscending,
        page: _page,
        size: _size,
        includeDeleted: _includeDeleted,
      );
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> setSearch(String value) async {
    _search = value;
    _page = 1;
    await load();
  }

  Future<void> sortBy(String field) async {
    if (_sortField == field) {
      _sortAscending = !_sortAscending;
    } else {
      _sortField = field;
      _sortAscending = true;
    }
    await load();
  }

  Future<void> goToPage(int page) async {
    _page = page;
    await load();
  }

  Future<void> setSize(int size) async {
    _size = size;
    _page = 1;
    await load();
  }

  Future<void> setIncludeDeleted(bool value) async {
    _includeDeleted = value;
    _page = 1;
    await load();
  }
}

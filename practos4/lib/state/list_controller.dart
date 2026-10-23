import 'package:flutter/foundation.dart';

import '../models/page_result.dart';
import 'load_status.dart';

abstract interface class PagedListController<T> implements Listenable {
  PageResult<T> get result;

  LoadStatus get status;

  String? get error;

  Set<int> get selected;

  bool get hasSelection;

  bool get includeDeleted;

  String get search;

  String get sortField;

  bool get sortAscending;

  Future<void> load();

  void toggleSelection(int id);

  Future<void> deleteSelected();

  Future<void> hardDeleteSelected();

  Future<void> restoreSelected();

  Future<void> deleteOne(int id);

  Future<void> hardDeleteOne(int id);

  Future<void> restoreOne(int id);

  Future<void> setSearch(String value);

  Future<void> setIncludeDeleted(bool value);

  Future<void> sortBy(String field);

  Future<void> goToPage(int page);

  Future<void> setSize(int size);
}

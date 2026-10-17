import 'package:flutter/foundation.dart';

import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/page_result.dart';
import '../repositories/animal_repository.dart';

enum LoadStatus { idle, loading, success, error }

class AnimalListNotifier extends ChangeNotifier {
  final AnimalRepository _repository;

  AnimalListNotifier(this._repository);

  AnimalQuery _query = const AnimalQuery();
  PageResult<Animal> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  AnimalQuery get query => _query;
  PageResult<Animal> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(AnimalQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(int id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }
}

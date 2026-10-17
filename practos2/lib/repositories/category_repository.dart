import '../models/category.dart';
import '../models/page_result.dart';

abstract interface class CategoryRepository {
  Future<PageResult<Category>> find({
    required String search,
    required String sortField,
    required bool sortAscending,
    required int page,
    required int size,
    required bool includeDeleted,
  });

  Future<Category?> findById(int id);

  Future<void> softDelete(int id);

  Future<void> hardDelete(int id);

  Future<void> restore(int id);
}

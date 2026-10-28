import '../models/category.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import 'api_repository_base.dart';
import 'category_repository.dart';

class ApiCategoryRepository extends ApiRepositoryBase<Category>
    implements CategoryRepository {
  ApiCategoryRepository(super.dio)
    : super(
        path: 'categories',
        fromJson: Category.fromJson,
        toJson: (category) => category.toJson(),
        cacheReferenceList: true,
      );

  @override
  Future<PageResult<Category>> find(ListQuery query) => fetchPage(
    listParams(query),
    reference:
        query.search.trim().isEmpty &&
        query.page == 1 &&
        query.size >= 100 &&
        !query.includeDeleted,
  );
}

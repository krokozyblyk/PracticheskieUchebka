import '../core/api_exceptions.dart';
import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/page_result.dart';
import 'animal_repository.dart';
import 'api_repository_base.dart';

class ApiAnimalRepository extends ApiRepositoryBase<Animal>
    implements AnimalRepository {
  ApiAnimalRepository(super.dio)
    : super(
        path: 'animals',
        fromJson: Animal.fromJson,
        toJson: (animal) => animal.toJson(),
      );

  @override
  Future<PageResult<Animal>> find(AnimalQuery query) => fetchPage({
    if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
    if (query.categoryId != null) 'categoryId': query.categoryId,
    if (query.supplierId != null) 'supplierId': query.supplierId,
    if (query.vetId != null) 'vetId': query.vetId,
    if (query.priceFrom != null) 'priceFrom': query.priceFrom,
    if (query.priceTo != null) 'priceTo': query.priceTo,
    'sort': '${query.sortField},${query.sortAscending ? 'asc' : 'desc'}',
    'page': query.page,
    'size': query.size,
    if (query.includeDeleted) 'includeDeleted': true,
  });

  @override
  Future<bool> existsSku(String sku, {int? exceptId}) async {
    final needle = sku.trim().toLowerCase();
    if (needle.isEmpty) return false;
    return retryRead(
      () => guard(() async {
        final response = await dio.get(
          '/animals',
          queryParameters: {'sku': needle, 'size': 5},
        );
        final page = pageFrom(Map<String, dynamic>.from(response.data as Map));
        return page.items.any(
          (animal) =>
              animal.id != exceptId && animal.sku.toLowerCase() == needle,
        );
      }),
    );
  }

  @override
  Future<int> countBySupplier(int supplierId) {
    return retryRead(
      () => guard(() async {
        final response = await dio.get(
          '/animals',
          queryParameters: {
            'supplierId': supplierId,
            'size': 1,
            'includeDeleted': true,
          },
        );
        final data = Map<String, dynamic>.from(response.data as Map);
        return data['total'] as int? ?? 0;
      }),
    );
  }
}

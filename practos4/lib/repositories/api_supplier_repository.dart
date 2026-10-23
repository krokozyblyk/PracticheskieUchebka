import '../models/list_query.dart';
import '../models/page_result.dart';
import '../models/supplier.dart';
import 'api_repository_base.dart';
import 'supplier_repository.dart';

class ApiSupplierRepository extends ApiRepositoryBase<Supplier>
    implements SupplierRepository {
  ApiSupplierRepository(super.dio)
      : super(
          path: 'suppliers',
          fromJson: Supplier.fromJson,
          toJson: (supplier) => supplier.toJson(),
          cacheReferenceList: true,
        );

  @override
  Future<PageResult<Supplier>> find(ListQuery query) => fetchPage(
        listParams(query),
        reference: query.search.trim().isEmpty &&
            query.page == 1 &&
            query.size >= 100 &&
            !query.includeDeleted,
      );
}

import '../models/list_query.dart';
import '../models/page_result.dart';
import '../models/vet.dart';
import 'api_repository_base.dart';
import 'vet_repository.dart';

class ApiVetRepository extends ApiRepositoryBase<Vet> implements VetRepository {
  ApiVetRepository(super.dio)
      : super(
          path: 'vets',
          fromJson: Vet.fromJson,
          toJson: (vet) => vet.toJson(),
          cacheReferenceList: true,
        );

  @override
  Future<PageResult<Vet>> find(ListQuery query) => fetchPage(
        listParams(query),
        reference: query.search.trim().isEmpty &&
            query.page == 1 &&
            query.size >= 100 &&
            !query.includeDeleted,
      );
}

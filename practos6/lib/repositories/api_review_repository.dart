import '../models/list_query.dart';
import '../models/page_result.dart';
import '../models/review.dart';
import 'api_repository_base.dart';
import 'review_repository.dart';

class ApiReviewRepository extends ApiRepositoryBase<Review>
    implements ReviewRepository {
  ApiReviewRepository(super.dio)
    : super(
        path: 'reviews',
        fromJson: Review.fromJson,
        toJson: (review) => review.toJson(),
      );

  @override
  Future<PageResult<Review>> find(ListQuery query) =>
      fetchPage(listParams(query));
}

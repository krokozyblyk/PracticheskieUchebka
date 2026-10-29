import '../models/list_query.dart';
import '../models/order.dart';
import '../models/page_result.dart';
import 'api_repository_base.dart';
import 'order_repository.dart';

class ApiOrderRepository extends ApiRepositoryBase<Order>
    implements OrderRepository {
  ApiOrderRepository(super.dio)
    : super(
        path: 'orders',
        fromJson: Order.fromJson,
        toJson: (order) => order.toJson(),
      );

  @override
  Future<PageResult<Order>> find(ListQuery query) =>
      fetchPage(listParams(query));
}

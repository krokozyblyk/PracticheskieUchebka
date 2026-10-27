import '../core/api_exceptions.dart';
import '../models/customer.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';
import 'api_repository_base.dart';
import 'customer_repository.dart';

class ApiCustomerRepository extends ApiRepositoryBase<Customer>
    implements CustomerRepository {
  ApiCustomerRepository(super.dio)
      : super(
          path: 'customers',
          fromJson: Customer.fromJson,
          toJson: (customer) => customer.toJson(),
        );

  @override
  Future<PageResult<Customer>> find(ListQuery query) =>
      fetchPage(listParams(query));

  @override
  Future<bool> existsEmail(String email, {int? exceptId}) async {
    final needle = email.trim().toLowerCase();
    if (needle.isEmpty) return false;
    return retryRead(
      () => guard(() async {
        final response = await dio.get(
          '/customers',
          queryParameters: {'search': needle, 'size': 50},
        );
        final page = pageFrom(Map<String, dynamic>.from(response.data as Map));
        return page.items.any(
          (customer) =>
              customer.id != exceptId &&
              customer.email.toLowerCase() == needle,
        );
      }),
    );
  }
}

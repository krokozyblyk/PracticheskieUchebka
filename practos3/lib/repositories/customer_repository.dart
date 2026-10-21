import '../models/customer.dart';
import 'entity_repository.dart';

abstract interface class CustomerRepository implements EntityRepository<Customer> {
  Future<bool> existsEmail(String email, {int? exceptId});
}

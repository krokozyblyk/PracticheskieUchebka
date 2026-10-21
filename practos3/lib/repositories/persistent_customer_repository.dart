import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';
import '../models/loyalty_card.dart';
import 'customer_repository.dart';
import 'persistent_entity_repository.dart';
import 'persistent_store.dart';

class PersistentCustomerRepository extends PersistentEntityRepository<Customer>
    implements CustomerRepository {
  PersistentCustomerRepository(SharedPreferences prefs)
      : super(PersistentStore<Customer>(
          prefs: prefs,
          key: 'customers_v1',
          fromJson: Customer.fromJson,
          toJson: (customer) => customer.toJson(),
          seed: () => seedCustomers,
        ));

  @override
  int idOf(Customer item) => item.id;

  @override
  Customer withId(Customer item, int id) => Customer(
        id: id,
        fullName: item.fullName,
        email: item.email,
        phone: item.phone,
        address: item.address,
        loyaltyCard: item.loyaltyCard,
        deletedAt: item.deletedAt,
      );

  @override
  Customer withDeletedAt(Customer item, DateTime? deletedAt) =>
      item.copyWith(deletedAt: deletedAt, clearDeletedAt: deletedAt == null);

  @override
  DateTime? deletedAtOf(Customer item) => item.deletedAt;

  @override
  List<String> searchText(Customer item) =>
      [item.fullName, item.email, item.phone, item.address];

  @override
  String sortText(Customer item, String field) => item.fullName;

  @override
  Future<bool> existsEmail(String email, {int? exceptId}) async {
    final needle = email.trim().toLowerCase();
    if (needle.isEmpty) return false;
    return items.any((customer) =>
        customer.email.trim().toLowerCase() == needle &&
        customer.id != exceptId);
  }
}

final List<Customer> seedCustomers = [
  Customer(
    id: 1,
    fullName: 'Дмитрий Злобин',
    email: 'zlobin@example.com',
    phone: '+7 915 000-11-22',
    address: 'г. Москва, ул. Лесная, 10',
    loyaltyCard: LoyaltyCard(
      cardNumber: 'LC-1001',
      issuedAt: DateTime(2025, 3, 12),
      discountPercent: 5,
    ),
  ),
  Customer(
    id: 2,
    fullName: 'Мария Иванова',
    email: 'ivanova@example.com',
    phone: '+7 915 000-33-44',
    address: 'г. Москва, ул. Полевая, 4',
    loyaltyCard: LoyaltyCard(
      cardNumber: 'LC-1002',
      issuedAt: DateTime(2024, 11, 2),
      discountPercent: 10,
    ),
  ),
  Customer(
    id: 3,
    fullName: 'Алексей Смирнов',
    email: 'smirnov@example.com',
    phone: '+7 915 000-55-66',
    address: 'г. Подольск, ул. Садовая, 8',
  ),
];

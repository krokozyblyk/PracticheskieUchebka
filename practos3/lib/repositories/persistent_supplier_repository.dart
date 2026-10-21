import 'package:shared_preferences/shared_preferences.dart';

import '../models/supplier.dart';
import 'persistent_entity_repository.dart';
import 'persistent_store.dart';

class PersistentSupplierRepository extends PersistentEntityRepository<Supplier> {
  PersistentSupplierRepository(SharedPreferences prefs)
      : super(PersistentStore<Supplier>(
          prefs: prefs,
          key: 'suppliers_v1',
          fromJson: Supplier.fromJson,
          toJson: (supplier) => supplier.toJson(),
          seed: () => seedSuppliers,
        ));

  @override
  int idOf(Supplier item) => item.id;

  @override
  Supplier withId(Supplier item, int id) => Supplier(
        id: id,
        name: item.name,
        contactPerson: item.contactPerson,
        phone: item.phone,
        email: item.email,
        deletedAt: item.deletedAt,
      );

  @override
  Supplier withDeletedAt(Supplier item, DateTime? deletedAt) =>
      item.copyWith(deletedAt: deletedAt, clearDeletedAt: deletedAt == null);

  @override
  DateTime? deletedAtOf(Supplier item) => item.deletedAt;

  @override
  List<String> searchText(Supplier item) =>
      [item.name, item.contactPerson, item.phone, item.email];

  @override
  String sortText(Supplier item, String field) =>
      field == 'contactPerson' ? item.contactPerson : item.name;
}

const List<Supplier> seedSuppliers = [
  Supplier(
    id: 1,
    name: 'ЗооМир',
    contactPerson: 'Иван Кузьмин',
    phone: '+7 900 111-22-33',
    email: 'sales@zoomir.ru',
  ),
  Supplier(
    id: 2,
    name: 'Питомец+',
    contactPerson: 'Анна Лебедева',
    phone: '+7 900 222-33-44',
    email: 'info@petsplus.ru',
  ),
  Supplier(
    id: 3,
    name: 'АкваДом',
    contactPerson: 'Сергей Орлов',
    phone: '+7 900 333-44-55',
    email: 'orders@akvadom.ru',
  ),
  Supplier(
    id: 4,
    name: 'Хвостик',
    contactPerson: 'Татьяна Ежова',
    phone: '+7 900 444-55-66',
    email: 'mail@hvostik.ru',
  ),
];

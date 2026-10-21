import 'package:shared_preferences/shared_preferences.dart';

import '../models/vet.dart';
import 'persistent_entity_repository.dart';
import 'persistent_store.dart';

class PersistentVetRepository extends PersistentEntityRepository<Vet> {
  PersistentVetRepository(SharedPreferences prefs)
      : super(PersistentStore<Vet>(
          prefs: prefs,
          key: 'vets_v1',
          fromJson: Vet.fromJson,
          toJson: (vet) => vet.toJson(),
          seed: () => seedVets,
        ));

  @override
  int idOf(Vet item) => item.id;

  @override
  Vet withId(Vet item, int id) => Vet(
        id: id,
        fullName: item.fullName,
        specializationCategoryId: item.specializationCategoryId,
        phone: item.phone,
        email: item.email,
        deletedAt: item.deletedAt,
      );

  @override
  Vet withDeletedAt(Vet item, DateTime? deletedAt) =>
      item.copyWith(deletedAt: deletedAt, clearDeletedAt: deletedAt == null);

  @override
  DateTime? deletedAtOf(Vet item) => item.deletedAt;

  @override
  List<String> searchText(Vet item) =>
      [item.fullName, item.phone, item.email];

  @override
  String sortText(Vet item, String field) => item.fullName;
}

const List<Vet> seedVets = [
  Vet(id: 1, fullName: 'Анна Петрова', specializationCategoryId: 1, phone: '+7 910 100-10-01', email: 'a.petrova@vet.ru'),
  Vet(id: 2, fullName: 'Игорь Соколов', specializationCategoryId: 2, phone: '+7 910 100-10-02', email: 'i.sokolov@vet.ru'),
  Vet(id: 3, fullName: 'Мария Волкова', specializationCategoryId: 3, phone: '+7 910 100-10-03', email: 'm.volkova@vet.ru'),
  Vet(id: 4, fullName: 'Ольга Смирнова', specializationCategoryId: 4, phone: '+7 910 100-10-04', email: 'o.smirnova@vet.ru'),
  Vet(id: 5, fullName: 'Павел Кузнецов', specializationCategoryId: 5, phone: '+7 910 100-10-05', email: 'p.kuznetsov@vet.ru'),
  Vet(id: 6, fullName: 'Елена Морозова', specializationCategoryId: 6, phone: '+7 910 100-10-06', email: 'e.morozova@vet.ru'),
];

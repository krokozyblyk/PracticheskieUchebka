import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import 'persistent_entity_repository.dart';
import 'persistent_store.dart';

class PersistentCategoryRepository extends PersistentEntityRepository<Category> {
  PersistentCategoryRepository(SharedPreferences prefs)
      : super(PersistentStore<Category>(
          prefs: prefs,
          key: 'categories_v1',
          fromJson: Category.fromJson,
          toJson: (category) => category.toJson(),
          seed: () => seedCategories,
        ));

  @override
  int idOf(Category item) => item.id;

  @override
  Category withId(Category item, int id) => Category(
        id: id,
        name: item.name,
        section: item.section,
        deletedAt: item.deletedAt,
      );

  @override
  Category withDeletedAt(Category item, DateTime? deletedAt) =>
      item.copyWith(deletedAt: deletedAt, clearDeletedAt: deletedAt == null);

  @override
  DateTime? deletedAtOf(Category item) => item.deletedAt;

  @override
  List<String> searchText(Category item) => [item.name, item.section];

  @override
  String sortText(Category item, String field) =>
      field == 'section' ? item.section : item.name;
}

const List<Category> seedCategories = [
  Category(id: 1, name: 'Кошки', section: 'Домашние'),
  Category(id: 2, name: 'Собаки', section: 'Домашние'),
  Category(id: 3, name: 'Птицы', section: 'Пернатые'),
  Category(id: 4, name: 'Грызуны', section: 'Мелкие'),
  Category(id: 5, name: 'Рыбки', section: 'Аквариум'),
  Category(id: 6, name: 'Рептилии', section: 'Экзотика'),
  Category(id: 7, name: 'Кролики', section: 'Мелкие'),
  Category(id: 8, name: 'Амфибии', section: 'Экзотика'),
];

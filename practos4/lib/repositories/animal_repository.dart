import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/page_result.dart';

abstract interface class AnimalRepository {
  Future<PageResult<Animal>> find(AnimalQuery query);

  Future<Animal?> findById(int id);

  Future<Animal> create(Animal animal);

  Future<Animal> update(Animal animal);

  Future<void> softDelete(int id);

  Future<void> hardDelete(int id);

  Future<void> restore(int id);

  Future<int> deleteMany(List<int> ids);

  Future<int> hardDeleteMany(List<int> ids);

  Future<int> restoreMany(List<int> ids);

  Future<bool> existsSku(String sku, {int? exceptId});

  Future<int> countBySupplier(int supplierId);
}

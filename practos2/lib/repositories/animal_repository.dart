import '../models/animal.dart';
import '../models/page_result.dart';
import '../models/animal_query.dart';

abstract interface class AnimalRepository {
  Future<PageResult<Animal>> find(AnimalQuery query);

  Future<Animal?> findById(int id);

  Future<Animal> create(Animal animal);

  Future<Animal> update(Animal animal);

  Future<void> softDelete(int id);

  Future<void> hardDelete(int id);

  Future<void> restore(int id);

  Future<int> deleteMany(List<int> ids);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:practos2/models/animal_query.dart';

void main() {
  group('AnimalQuery', () {
    test('сброс фильтра через null (не _unset)', () {
      const query = AnimalQuery(categoryId: 2, supplierId: 1, page: 3);
      final updated = query.copyWith(categoryId: null);
      expect(updated.categoryId, isNull);
      expect(updated.supplierId, 1);
      expect(updated.page, 1);
    });

    test('не переданный параметр сохраняет старое значение', () {
      const query = AnimalQuery(categoryId: 2, supplierId: 1);
      final updated = query.copyWith(search: 'кот');
      expect(updated.categoryId, 2);
      expect(updated.supplierId, 1);
    });

    test('смена условий отбора возвращает на первую страницу', () {
      const query = AnimalQuery(page: 7, search: 'кот');
      final updated = query.copyWith(search: 'пёс');
      expect(updated.page, 1);
    });

    test('прямая передача page сохраняет его', () {
      const query = AnimalQuery(page: 1);
      final updated = query.copyWith(page: 3);
      expect(updated.page, 3);
    });

    test('сброс диапазона цены', () {
      const query = AnimalQuery(priceFrom: 100, priceTo: 500);
      final updated = query.copyWith(priceFrom: null, priceTo: null);
      expect(updated.priceFrom, isNull);
      expect(updated.priceTo, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:practos2/models/page_result.dart';

void main() {
  group('PageResult', () {
    test('totalPages считает полные и неполные страницы', () {
      expect(
        const PageResult(items: [], page: 1, size: 10, total: 25).totalPages,
        3,
      );
      expect(
        const PageResult(items: [], page: 1, size: 10, total: 20).totalPages,
        2,
      );
      expect(
        const PageResult(items: [], page: 1, size: 10, total: 1).totalPages,
        1,
      );
    });

    test('пустой результат даёт одну страницу', () {
      final empty = PageResult<Object>.empty();
      expect(empty.totalPages, 1);
      expect(empty.total, 0);
      expect(empty.items, isEmpty);
    });

    test('hasPrevious и hasNext', () {
      const first =
          PageResult(items: [], page: 1, size: 10, total: 25);
      const middle =
          PageResult(items: [], page: 2, size: 10, total: 25);
      const last = PageResult(items: [], page: 3, size: 10, total: 25);

      expect(first.hasPrevious, false);
      expect(first.hasNext, true);
      expect(middle.hasPrevious, true);
      expect(middle.hasNext, true);
      expect(last.hasPrevious, true);
      expect(last.hasNext, false);
    });
  });
}

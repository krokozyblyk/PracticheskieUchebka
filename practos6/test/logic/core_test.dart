import 'package:flutter_test/flutter_test.dart';
import 'package:practos6/logic/permissions.dart';
import 'package:practos6/logic/session_rules.dart';
import 'package:practos6/logic/validators.dart';
import 'package:practos6/models/animal.dart';
import 'package:practos6/models/role.dart';

void main() {
  group('Валидаторы', () {
    test('обязательное поле отклоняет пустую строку', () {
      expect(requiredValidator(''), isNotNull);
      expect(requiredValidator('   '), isNotNull);
      expect(requiredValidator('Кот'), isNull);
    });

    test('проверка длины учитывает границы', () {
      final validator = lengthValidator(3, 10);
      expect(validator('ab'), isNotNull);
      expect(validator('abc'), isNull);
      expect(validator('abcdefghijk'), isNotNull);
    });

    test('почта проверяется по формату', () {
      expect(emailValidator('user@example.com'), isNull);
      expect(emailValidator('user@'), isNotNull);
      expect(emailValidator('example.com'), isNotNull);
    });

    test('телефон проверяется по количеству цифр', () {
      expect(phoneValidator('+7 900 111-22-33'), isNull);
      expect(phoneValidator('123'), isNotNull);
    });

    test('цена должна быть положительной', () {
      expect(priceValidator('1500'), isNull);
      expect(priceValidator('0'), isNotNull);
      expect(priceValidator('-5'), isNotNull);
    });

    test('количество не может быть отрицательным', () {
      expect(quantityValidator('0'), isNull);
      expect(quantityValidator('-1'), isNotNull);
      expect(quantityValidator('10001'), isNotNull);
    });

    test('артикул проверяется по шаблону', () {
      expect(skuValidator('AN-001'), isNull);
      expect(skuValidator('ан-001'), isNotNull);
      expect(skuValidator('A'), isNotNull);
    });

    test('диапазон целых чисел', () {
      final validator = intRangeValidator(0, 50);
      expect(validator('25'), isNull);
      expect(validator('-1'), isNotNull);
      expect(validator('51'), isNotNull);
    });
  });

  group('Модели', () {
    test('Animal.fromJson без полей не падает', () {
      final animal = Animal.fromJson({'id': 1});
      expect(animal.name, '');
      expect(animal.categoryIds, isEmpty);
      expect(animal.vetIds, isEmpty);
      expect(animal.supplierId, 0);
    });

    test('Animal.fromJson разбирает развёрнутые связи', () {
      final animal = Animal.fromJson({
        'id': 5,
        'name': 'Барсик',
        'supplier': {'id': 2, 'name': 'ЗооМир'},
        'categories': [
          {'id': 3, 'name': 'Кошки'},
        ],
        'vets': [
          {'id': 4, 'fullName': 'Анна Петрова'},
        ],
      });
      expect(animal.supplierId, 2);
      expect(animal.categoryIds, [3]);
      expect(animal.vetIds, [4]);
    });
  });

  group('Права ролей', () {
    test('матрица прав различается по ролям', () {
      expect(Role.customer.can(Permission.viewCatalog), isTrue);
      expect(Role.customer.can(Permission.viewProfile), isTrue);
      expect(Role.customer.can(Permission.manageCatalog), isFalse);
      expect(Role.specialist.can(Permission.manageCatalog), isTrue);
      expect(Role.specialist.can(Permission.deleteSoft), isTrue);
      expect(Role.specialist.can(Permission.deleteHard), isFalse);
      expect(Role.admin.can(Permission.manageUsers), isTrue);
      expect(Role.admin.can(Permission.deleteHard), isTrue);
      expect(Role.admin.can(Permission.manageCatalog), isFalse);
    });

    test('доступ к маршрутам зависит от роли', () {
      expect(canOpenPath(Role.customer, '/animals'), isTrue);
      expect(canOpenPath(Role.customer, '/users'), isFalse);
      expect(canOpenPath(Role.customer, '/animals/new'), isFalse);
      expect(canOpenPath(Role.specialist, '/animals/new'), isTrue);
      expect(canOpenPath(Role.specialist, '/statistics'), isFalse);
      expect(canOpenPath(Role.admin, '/users'), isTrue);
      expect(canOpenPath(Role.admin, '/animals/new'), isFalse);
    });
  });

  group('Правила сессии', () {
    const rules = SessionRules(
      idle: Duration(minutes: 3),
      warning: Duration(seconds: 30),
      max: Duration(minutes: 60),
    );

    test('предупреждение появляется за 30 секунд', () {
      expect(rules.shouldWarn(const Duration(seconds: 149)), isFalse);
      expect(rules.shouldWarn(const Duration(seconds: 150)), isTrue);
      expect(
        rules.warningRemaining(const Duration(seconds: 160)),
        const Duration(seconds: 20),
      );
      expect(rules.idleExpired(const Duration(minutes: 3)), isTrue);
    });

    test('общий лимит завершает сессию', () {
      expect(rules.maxExpired(const Duration(minutes: 59)), isFalse);
      expect(rules.maxExpired(const Duration(minutes: 60)), isTrue);
    });
  });
}

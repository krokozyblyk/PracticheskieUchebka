import 'package:flutter_test/flutter_test.dart';
import 'package:practos1/logic/currency.dart';
import 'package:practos1/logic/formatting.dart';

void main() {
  group('convertCurrency', () {
    test('конвертирует доллары в рубли', () {
      final result = convertCurrency(from: 'USD', to: 'RUB', amount: '100');
      expect(result, isA<ConversionSuccess>());
      expect((result as ConversionSuccess).value, closeTo(9250, 0.01));
    });

    test('конвертирует рубли в доллары', () {
      final result = convertCurrency(from: 'RUB', to: 'USD', amount: '9250');
      expect((result as ConversionSuccess).value, closeTo(100, 0.01));
    });

    test('одинаковая валюта даёт ту же сумму', () {
      final result = convertCurrency(from: 'EUR', to: 'EUR', amount: '50');
      expect((result as ConversionSuccess).value, 50);
    });

    test('сообщает о неизвестной валюте', () {
      final result = convertCurrency(from: 'USD', to: 'XXX', amount: '10');
      expect(result, isA<ConversionFailure>());
      expect((result as ConversionFailure).message, 'Неизвестная валюта');
    });

    test('сообщает о нечисловой сумме', () {
      final result = convertCurrency(from: 'USD', to: 'RUB', amount: 'много');
      expect(result, isA<ConversionFailure>());
      expect(
        (result as ConversionFailure).message,
        'В адресе передано не число',
      );
    });

    test('сообщает об отсутствии обязательных параметров', () {
      expect(
        convertCurrency(from: null, to: 'RUB', amount: '10'),
        isA<ConversionFailure>(),
      );
      expect(
        convertCurrency(from: 'USD', to: 'RUB', amount: ''),
        isA<ConversionFailure>(),
      );
    });

    test('не принимает отрицательную сумму', () {
      final result = convertCurrency(from: 'USD', to: 'RUB', amount: '-5');
      expect(
        (result as ConversionFailure).message,
        'Сумма не может быть отрицательной',
      );
    });

    test('поддерживает не менее пяти валют', () {
      expect(currencies.length, greaterThanOrEqualTo(5));
      expect(currencyByCode('RUB'), isNotNull);
      expect(currencyByCode('QQQ'), isNull);
    });

    test('округляет денежную сумму до двух знаков', () {
      expect(formatMoney(9250.4567), '9250.46');
    });
  });
}
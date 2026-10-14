import 'package:flutter_test/flutter_test.dart';
import 'package:practos1/logic/calculator.dart';
import 'package:practos1/logic/formatting.dart';

void main() {
  group('calculate', () {
    test('складывает два числа', () {
      final result = calculate(a: '12.5', operation: '+', b: '4');
      expect(result, isA<CalcSuccess>());
      expect((result as CalcSuccess).value, 16.5);
    });

    test('вычитает два числа', () {
      final result = calculate(a: '12', operation: '-', b: '4');
      expect((result as CalcSuccess).value, 8);
    });

    test('умножает два числа', () {
      final result = calculate(a: '7', operation: '*', b: '6');
      expect((result as CalcSuccess).value, 42);
    });

    test('делит два числа', () {
      final result = calculate(a: '9', operation: '/', b: '2');
      expect((result as CalcSuccess).value, 4.5);
    });

    test('принимает запятую как десятичный разделитель', () {
      final result = calculate(a: '3,5', operation: '+', b: '1,5');
      expect((result as CalcSuccess).value, 5);
    });

    test('не делит на ноль', () {
      final result = calculate(a: '9', operation: '/', b: '0');
      expect(result, isA<CalcFailure>());
      expect(
        (result as CalcFailure).message,
        'Деление на ноль невозможно',
      );
    });

    test('сообщает о нечисловых значениях', () {
      final result = calculate(a: 'abc', operation: '+', b: '2');
      expect(result, isA<CalcFailure>());
      expect(
        (result as CalcFailure).message,
        'В адресе переданы не числа',
      );
    });

    test('сообщает о неизвестной операции', () {
      final result = calculate(a: '2', operation: '%', b: '2');
      expect(result, isA<CalcFailure>());
      expect(
        (result as CalcFailure).message,
        'Неизвестная операция',
      );
    });

    test('сообщает об отсутствии обязательных параметров', () {
      expect(
        calculate(a: null, operation: '+', b: '2'),
        isA<CalcFailure>(),
      );
      expect(
        calculate(a: '2', operation: '+', b: ''),
        isA<CalcFailure>(),
      );
      expect(
        calculate(a: '2', operation: null, b: '2'),
        isA<CalcFailure>(),
      );
    });

    test('разрешает отрицательные числа и ноль', () {
      expect((calculate(a: '-5', operation: '+', b: '3') as CalcSuccess).value, -2);
      expect((calculate(a: '0', operation: '*', b: '3') as CalcSuccess).value, 0);
    });
  });

  group('formatNumber', () {
    test('убирает длинную дробную часть', () {
      expect(formatNumber(3.3333333333333335), '3.3333333333');
    });

    test('убирает хвостовые нули', () {
      expect(formatNumber(4.0), '4');
      expect(formatNumber(16.5), '16.5');
    });

    test('не показывает бесконечность', () {
      expect(formatNumber(double.infinity), 'не определено');
    });
  });

  group('parseNumber', () {
    test('разбирает положительные, отрицательные и дробные числа', () {
      expect(parseNumber(' 10 '), 10);
      expect(parseNumber('-2,25'), -2.25);
      expect(parseNumber('0'), 0);
    });

    test('возвращает null для пустого и нечислового ввода', () {
      expect(parseNumber(null), isNull);
      expect(parseNumber('   '), isNull);
      expect(parseNumber('1/2'), isNull);
    });
  });
}
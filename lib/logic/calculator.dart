import 'formatting.dart';

sealed class CalcResult {
  const CalcResult();
}

class CalcSuccess extends CalcResult {
  final double value;

  const CalcSuccess(this.value);
}

class CalcFailure extends CalcResult {
  final String message;

  const CalcFailure(this.message);
}

const List<String> calculatorOperations = ['+', '-', '*', '/'];

const Map<String, String> calculatorOperationTitles = {
  '+': 'Сложение',
  '-': 'Вычитание',
  '*': 'Умножение',
  '/': 'Деление',
};

CalcResult calculate({
  required String? a,
  required String? operation,
  required String? b,
}) {
  final missing = a == null ||
      b == null ||
      operation == null ||
      a.trim().isEmpty ||
      b.trim().isEmpty ||
      operation.trim().isEmpty;
  if (missing) {
    return const CalcFailure('В адресе не хватает обязательных параметров');
  }

  final left = parseNumber(a);
  final right = parseNumber(b);
  if (left == null || right == null) {
    return const CalcFailure('В адресе переданы не числа');
  }

  return switch (operation) {
    '+' => CalcSuccess(left + right),
    '-' => CalcSuccess(left - right),
    '*' => CalcSuccess(left * right),
    '/' => right == 0
        ? const CalcFailure('Деление на ноль невозможно')
        : CalcSuccess(left / right),
    _ => const CalcFailure('Неизвестная операция'),
  };
}

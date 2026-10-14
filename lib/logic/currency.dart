import 'formatting.dart';

class Currency {
  final String code;
  final String name;
  final double rateToRub;

  const Currency({
    required this.code,
    required this.name,
    required this.rateToRub,
  });
}

const List<Currency> currencies = [
  Currency(code: 'RUB', name: 'Российский рубль', rateToRub: 1),
  Currency(code: 'USD', name: 'Доллар США', rateToRub: 92.5),
  Currency(code: 'EUR', name: 'Евро', rateToRub: 99.8),
  Currency(code: 'CNY', name: 'Китайский юань', rateToRub: 12.7),
  Currency(code: 'KZT', name: 'Казахстанский тенге', rateToRub: 0.19),
  Currency(code: 'TRY', name: 'Турецкая лира', rateToRub: 2.75),
  Currency(code: 'GBP', name: 'Фунт стерлингов', rateToRub: 117.4),
];

Currency? currencyByCode(String? code) {
  if (code == null) return null;
  for (final currency in currencies) {
    if (currency.code == code) return currency;
  }
  return null;
}

sealed class ConversionResult {
  const ConversionResult();
}

class ConversionSuccess extends ConversionResult {
  final double value;

  const ConversionSuccess(this.value);
}

class ConversionFailure extends ConversionResult {
  final String message;

  const ConversionFailure(this.message);
}

ConversionResult convertCurrency({
  required String? from,
  required String? to,
  required String? amount,
}) {
  final missing = from == null ||
      to == null ||
      amount == null ||
      from.trim().isEmpty ||
      to.trim().isEmpty ||
      amount.trim().isEmpty;
  if (missing) {
    return const ConversionFailure('В адресе не хватает обязательных параметров');
  }

  final source = currencyByCode(from);
  final target = currencyByCode(to);
  if (source == null || target == null) {
    return const ConversionFailure('Неизвестная валюта');
  }

  final value = parseNumber(amount);
  if (value == null) {
    return const ConversionFailure('В адресе передано не число');
  }
  if (value < 0) {
    return const ConversionFailure('Сумма не может быть отрицательной');
  }

  return ConversionSuccess(value * source.rateToRub / target.rateToRub);
}

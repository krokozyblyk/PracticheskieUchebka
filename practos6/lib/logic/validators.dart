int? parseIntValue(String? value) => int.tryParse((value ?? '').trim());

double? parseDoubleValue(String? value) =>
    double.tryParse((value ?? '').trim().replaceAll(',', '.'));

String? Function(String?) combineValidators(
  List<String? Function(String?)> validators,
) {
  return (value) {
    for (final validator in validators) {
      final message = validator(value);
      if (message != null) return message;
    }
    return null;
  };
}

String? requiredValidator(
  String? value, {
  String message = 'Обязательное поле',
}) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? Function(String?) minLengthValidator(int min) {
  return (value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < min) return 'Минимум $min символов';
    return null;
  };
}

String? Function(String?) maxLengthValidator(int max) {
  return (value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) return 'Максимум $max символов';
    return null;
  };
}

String? Function(String?) lengthValidator(int min, int max) {
  return combineValidators([minLengthValidator(min), maxLengthValidator(max)]);
}

String? Function(String?) intRangeValidator(int min, int max) {
  return (value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 'Введите целое число';
    if (parsed < min || parsed > max) return 'Допустимо от $min до $max';
    return null;
  };
}

String? priceValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = parseDoubleValue(value);
  if (parsed == null) return 'Введите число';
  if (parsed <= 0) return 'Цена должна быть больше нуля';
  if (parsed > 1000000) return 'Слишком большая цена';
  return null;
}

String? quantityValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = int.tryParse(value.trim());
  if (parsed == null) return 'Введите целое число';
  if (parsed < 0) return 'Количество не может быть отрицательным';
  if (parsed > 10000) return 'Слишком большое количество';
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final email = value.trim();
  final pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  if (!pattern.hasMatch(email)) return 'Неверный формат почты';
  return null;
}

String? phoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final digits = value.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length < 10 || digits.length > 12) {
    return 'Неверный формат телефона';
  }
  return null;
}

String? skuValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final pattern = RegExp(r'^[A-Za-z0-9-]{3,20}$');
  if (!pattern.hasMatch(value.trim())) {
    return 'Артикул: 3–20 символов, латиница, цифры и дефис';
  }
  return null;
}

String? discountValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = int.tryParse(value.trim());
  if (parsed == null) return 'Введите целое число';
  if (parsed < 0 || parsed > 100) return 'Скидка от 0 до 100%';
  return null;
}

String? cardNumberValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final pattern = RegExp(r'^[A-Za-z0-9-]{4,20}$');
  if (!pattern.hasMatch(value.trim())) {
    return 'Номер карты: 4–20 символов, латиница, цифры и дефис';
  }
  return null;
}

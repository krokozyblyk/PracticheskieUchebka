import 'package:flutter/material.dart';

import '../core/api_exceptions.dart';

void showApiError(BuildContext context, Object error) {
  final message = error is ApiException
      ? error.message
      : 'Не удалось выполнить операцию.';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

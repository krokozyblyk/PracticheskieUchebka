import 'package:flutter/material.dart';

import '../logic/currency.dart';
import '../logic/formatting.dart';
import '../widgets/result_views.dart';
import '../widgets/theme_toggle_button.dart';

class ConverterResultScreen extends StatelessWidget {
  const ConverterResultScreen({
    super.key,
    required this.query,
    required this.location,
  });

  final Map<String, String> query;
  final String location;

  @override
  Widget build(BuildContext context) {
    final from = query['from'];
    final to = query['to'];
    final amount = query['sum'];
    final source = currencyByCode(from);
    final target = currencyByCode(to);
    final title = 'Конвертация валюты';
    final result = convertCurrency(from: from, to: to, amount: amount);

    final expression = switch (result) {
      ConversionSuccess() =>
        '${formatMoney(parseNumber(amount) ?? 0)} ${source?.code ?? from ?? '?'} → ${target?.code ?? to ?? '?'}',
      ConversionFailure() =>
        '${amount ?? '—'} ${source?.code ?? from ?? '?'} → ${target?.code ?? to ?? '?'}',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат конвертации'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: switch (result) {
        ConversionSuccess(:final value) => ResultSuccessView(
            title: title,
            expression: expression,
            value: '${formatMoney(value)} ${target?.code ?? to ?? ''}',
            location: location,
            backPath: '/converter',
            backLabel: 'Вернуться к конвертеру',
          ),
        ConversionFailure(:final message) => ResultFailureView(
            title: title,
            message: message,
            location: location,
            backPath: '/converter',
            backLabel: 'Вернуться к конвертеру',
          ),
      },
    );
  }
}

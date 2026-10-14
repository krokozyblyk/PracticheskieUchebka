import 'package:flutter/material.dart';

import '../logic/calculator.dart';
import '../logic/formatting.dart';
import '../widgets/result_views.dart';
import '../widgets/theme_toggle_button.dart';

class CalculationResultScreen extends StatelessWidget {
  const CalculationResultScreen({
    super.key,
    required this.query,
    required this.location,
  });

  final Map<String, String> query;
  final String location;

  @override
  Widget build(BuildContext context) {
    final a = query['a'];
    final operation = query['op'];
    final b = query['b'];
    final title = calculatorOperationTitles[operation] ?? 'Результат вычисления';
    final result = calculate(a: a, operation: operation, b: b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат вычисления'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: switch (result) {
        CalcSuccess(:final value) => ResultSuccessView(
            title: title,
            expression: '${a ?? '—'} ${operation ?? '?'} ${b ?? '—'}',
            value: formatNumber(value),
            location: location,
            backPath: '/calculator',
            backLabel: 'Вернуться к калькулятору',
          ),
        CalcFailure(:final message) => ResultFailureView(
            title: title,
            message: message,
            location: location,
            backPath: '/calculator',
            backLabel: 'Вернуться к калькулятору',
          ),
      },
    );
  }
}

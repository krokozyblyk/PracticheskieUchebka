import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/calculator.dart';
import '../logic/formatting.dart';
import '../widgets/responsive_form.dart';
import '../widgets/theme_toggle_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  String _operation = calculatorOperations.first;

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите число';
    if (parseNumber(value) == null) return 'Это не число';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final a = _aController.text.trim().replaceAll(',', '.');
    final b = _bController.text.trim().replaceAll(',', '.');
    final op = Uri.encodeComponent(_operation);
    context.go('/calculator/result?a=$a&op=$op&b=$b');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: ResponsiveForm(
        formKey: _formKey,
        children: [
          TextFormField(
            controller: _aController,
            decoration: const InputDecoration(
              labelText: 'Первое число',
              hintText: 'например, 12.5',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            validator: _numberValidator,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _operation,
            decoration: const InputDecoration(
              labelText: 'Операция',
              border: OutlineInputBorder(),
            ),
            items: calculatorOperations
                .map(
                  (operation) => DropdownMenuItem(
                    value: operation,
                    child: Text(
                      '$operation — ${calculatorOperationTitles[operation]}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _operation = value ?? '+');
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bController,
            decoration: const InputDecoration(
              labelText: 'Второе число',
              hintText: 'например, 4',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            validator: _numberValidator,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Вычислить'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
            label: const Text('На главную'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_settings.dart';
import '../logic/currency.dart';
import '../logic/formatting.dart';
import '../widgets/responsive_form.dart';
import '../widgets/theme_toggle_button.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late String _from;
  late String _to;

  @override
  void initState() {
    super.initState();
    _from = AppSettings.instance.converterFrom;
    _to = AppSettings.instance.converterTo;
    if (currencyByCode(_from) == null) _from = 'USD';
    if (currencyByCode(_to) == null) _to = 'RUB';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> _items(bool isSource) {
    return currencies
        .map(
          (currency) => DropdownMenuItem(
            value: currency.code,
            child: Text('${currency.code} — ${currency.name}'),
          ),
        )
        .toList();
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите сумму';
    final parsed = parseNumber(value);
    if (parsed == null) return 'Это не число';
    if (parsed < 0) return 'Сумма не может быть отрицательной';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = _amountController.text.trim().replaceAll(',', '.');
    AppSettings.instance.saveCurrencyPair(_from, _to);
    context.go('/converter/result?from=$_from&to=$_to&sum=$amount');
  }

  void _swap() {
    setState(() {
      final previous = _from;
      _from = _to;
      _to = previous;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: ResponsiveForm(
        formKey: _formKey,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _from,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Из какой валюты',
                    border: OutlineInputBorder(),
                  ),
                  items: _items(true),
                  onChanged: (value) {
                    setState(() => _from = value ?? _from);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Поменять местами',
                onPressed: _swap,
                icon: const Icon(Icons.swap_horiz),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _to,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'В какую валюту',
                    border: OutlineInputBorder(),
                  ),
                  items: _items(false),
                  onChanged: (value) {
                    setState(() => _to = value ?? _to);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Сумма',
              hintText: 'например, 100',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _amountValidator,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Конвертировать'),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/responsive_form.dart';
import '../widgets/theme_toggle_button.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Страница не найдена'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: ResponsiveForm(
        children: [
          Text(
            '404',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Адрес "$location" не существует',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
            label: const Text('На главную'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/calculator'),
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Калькулятор'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/converter'),
            icon: const Icon(Icons.currency_exchange_outlined),
            label: const Text('Конвертер валют'),
          ),
        ],
      ),
    );
  }
}

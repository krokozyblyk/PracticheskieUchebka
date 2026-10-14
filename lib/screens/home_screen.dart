import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/theme_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Калькулятор и конвертер валют',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go('/calculator'),
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Калькулятор'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.go('/converter'),
                  icon: const Icon(Icons.currency_exchange_outlined),
                  label: const Text('Конвертер валют'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LocationPanel extends StatelessWidget {
  const LocationPanel({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Адрес экрана', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SelectableText(
              location,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultSuccessView extends StatelessWidget {
  const ResultSuccessView({
    super.key,
    required this.title,
    required this.expression,
    required this.value,
    required this.location,
    required this.backPath,
    required this.backLabel,
  });

  final String title;
  final String expression;
  final String value;
  final String location;
  final String backPath;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                expression,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LocationPanel(location: location),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(backPath),
                icon: const Icon(Icons.edit_outlined),
                label: Text(backLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultFailureView extends StatelessWidget {
  const ResultFailureView({
    super.key,
    required this.title,
    required this.message,
    required this.location,
    required this.backPath,
    required this.backLabel,
  });

  final String title;
  final String message;
  final String location;
  final String backPath;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              LocationPanel(location: location),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(backPath),
                icon: const Icon(Icons.edit_outlined),
                label: Text(backLabel),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('На главную'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
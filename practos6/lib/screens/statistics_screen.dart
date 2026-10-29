import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../core/auth_api.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatsResult? _stats;
  bool _loading = true;
  String? _error;

  static const _titles = {
    'animals': 'Животные',
    'categories': 'Категории',
    'suppliers': 'Поставщики',
    'vets': 'Ветеринары',
    'customers': 'Покупатели',
    'users': 'Пользователи',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final stats = await context.read<AuthApi>().stats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
      showApiError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Статистика',
      currentPath: '/statistics',
      maxWidth: 1200,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final counts = _stats!.counts;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Сводка по данным', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final key in _titles.keys)
              SizedBox(
                width: 240,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titles[key]!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Активных: ${counts[key]?.active ?? 0}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text('Удалённых: ${counts[key]?.deleted ?? 0}'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _buildDomainMetrics(context),
      ],
    );
  }

  Widget _buildDomainMetrics(BuildContext context) {
    final metrics = _stats!.metrics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Продажи и отзывы', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              title: 'Выручка',
              value: '${metrics.revenue.toStringAsFixed(0)} ₽',
            ),
            _MetricCard(title: 'Заказов', value: '${metrics.orders}'),
            _MetricCard(
              title: 'Средняя оценка',
              value: metrics.averageRating.toStringAsFixed(1),
            ),
            _MetricCard(title: 'Отзывов', value: '${metrics.reviews}'),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 420,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Топ животных по продажам',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (metrics.topAnimals.isEmpty)
                        const Text('Пока нет продаж'),
                      for (final item in metrics.topAnimals)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(item.name)),
                              Text('${item.quantity} шт.'),
                              const SizedBox(width: 12),
                              Text('${item.revenue.toStringAsFixed(0)} ₽'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Низкие остатки',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (metrics.lowStock.isEmpty)
                        const Text('Все позиции в наличии'),
                      for (final item in metrics.lowStock)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(item.name)),
                              Text('${item.quantity} шт.'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

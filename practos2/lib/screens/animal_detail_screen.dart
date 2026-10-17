import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../models/supplier.dart';
import '../repositories/animal_repository.dart';

class AnimalDetailScreen extends StatefulWidget {
  final int id;

  const AnimalDetailScreen({super.key, required this.id});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  Animal? _animal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final animal = await context.read<AnimalRepository>().findById(widget.id);
    if (!mounted) return;
    setState(() {
      _animal = animal;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Карточка животного')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _animal == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Животное не найдено'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.go('/'),
                        child: const Text('К списку'),
                      ),
                    ],
                  ),
                )
              : _buildDetail(context, _animal!),
    );
  }

  Widget _buildDetail(BuildContext context, Animal animal) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(animal.name, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                _row('Вид', animal.species),
                _row('Возраст', '${animal.age} г.'),
                _row('Цена', '${animal.price.toStringAsFixed(0)} ₽'),
                _row('Поставщик', supplierName(animal.supplierId)),
                _row('Категории', animal.categoryIds.join(', ')),
                _row('В наличии', '${animal.quantity} шт.'),
                if (animal.isDeleted) _row('Статус', 'Удалено'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('К списку'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/supplier.dart';
import '../repositories/animal_repository.dart';
import '../repositories/supplier_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/detail_scaffold.dart';

class SupplierDetailScreen extends StatefulWidget {
  final int id;

  const SupplierDetailScreen({super.key, required this.id});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  Supplier? _supplier;
  int _linkedAnimals = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supplierRepository = context.read<SupplierRepository>();
    final animalRepository = context.read<AnimalRepository>();
    final supplier = await supplierRepository.findById(widget.id);
    final linked = await animalRepository.countBySupplier(widget.id);
    if (!mounted) return;
    setState(() {
      _supplier = supplier;
      _linkedAnimals = linked;
      _loading = false;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/suppliers');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка поставщика')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final supplier = _supplier;
    if (supplier == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка поставщика')),
        body: const Center(child: Text('Поставщик не найден')),
      );
    }

    return DetailScaffold(
      title: 'Карточка поставщика',
      currentPath: '/suppliers',
      isDeleted: supplier.isDeleted,
      rows: [
        DetailRow('Название', supplier.name),
        DetailRow('Контактное лицо', supplier.contactPerson),
        DetailRow('Телефон', supplier.phone),
        DetailRow('Почта', supplier.email),
        DetailRow('Связанных животных', '$_linkedAnimals'),
      ],
      onEdit: () => context.push('/suppliers/${supplier.id}/edit'),
      onDelete: () async {
        if (_linkedAnimals > 0) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Удаление невозможно'),
              content: Text(
                'На поставщика ссылаются животные. '
                'Связанных записей: $_linkedAnimals.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Понятно'),
                ),
              ],
            ),
          );
          return;
        }
        final repository = context.read<SupplierRepository>();
        final notifier = context.read<EntityListNotifier<Supplier>>();
        await repository.softDelete(supplier.id);
        await notifier.load();
        _close();
      },
      onRestore: () async {
        final repository = context.read<SupplierRepository>();
        final notifier = context.read<EntityListNotifier<Supplier>>();
        await repository.restore(supplier.id);
        await notifier.load();
        await _load();
      },
      onHardDelete: () async {
        if (_linkedAnimals > 0) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Удаление невозможно'),
              content: Text(
                'На поставщика ссылаются животные. '
                'Связанных записей: $_linkedAnimals.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Понятно'),
                ),
              ],
            ),
          );
          return;
        }
        final repository = context.read<SupplierRepository>();
        final notifier = context.read<EntityListNotifier<Supplier>>();
        await repository.hardDelete(supplier.id);
        await notifier.load();
        _close();
      },
    );
  }
}

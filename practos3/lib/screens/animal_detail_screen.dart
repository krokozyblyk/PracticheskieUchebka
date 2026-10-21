import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../models/category.dart' as model;
import '../models/list_query.dart';
import '../models/supplier.dart';
import '../models/vet.dart';
import '../repositories/animal_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/supplier_repository.dart';
import '../repositories/vet_repository.dart';
import '../state/animal_list_notifier.dart';
import '../widgets/detail_scaffold.dart';

class AnimalDetailScreen extends StatefulWidget {
  final int id;

  const AnimalDetailScreen({super.key, required this.id});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  Animal? _animal;
  List<model.Category> _categories = [];
  List<Supplier> _suppliers = [];
  List<Vet> _vets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final animalRepository = context.read<AnimalRepository>();
    final categoryRepository = context.read<CategoryRepository>();
    final supplierRepository = context.read<SupplierRepository>();
    final vetRepository = context.read<VetRepository>();
    final animal = await animalRepository.findById(widget.id);
    final categories =
        await categoryRepository.find(const ListQuery(size: 1000));
    final suppliers =
        await supplierRepository.find(const ListQuery(size: 1000));
    final vets = await vetRepository.find(const ListQuery(size: 1000));
    if (!mounted) return;
    setState(() {
      _animal = animal;
      _categories = categories.items;
      _suppliers = suppliers.items;
      _vets = vets.items;
      _loading = false;
    });
  }

  String _supplierName(int id) {
    for (final supplier in _suppliers) {
      if (supplier.id == id) return supplier.name;
    }
    return '—';
  }

  String _categoryNames(List<int> ids) {
    if (ids.isEmpty) return '—';
    return ids
        .map((id) {
          for (final category in _categories) {
            if (category.id == id) return category.name;
          }
          return '—';
        })
        .join(', ');
  }

  String _vetNames(List<int> ids) {
    if (ids.isEmpty) return '—';
    return ids
        .map((id) {
          for (final vet in _vets) {
            if (vet.id == id) return vet.fullName;
          }
          return '—';
        })
        .join(', ');
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/animals');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка животного')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final animal = _animal;
    if (animal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка животного')),
        body: const Center(child: Text('Животное не найдено')),
      );
    }

    return DetailScaffold(
      title: 'Карточка животного',
      currentPath: '/animals',
      isDeleted: animal.isDeleted,
      rows: [
        DetailRow('Кличка', animal.name),
        DetailRow('Артикул', animal.sku),
        DetailRow('Вид', animal.species),
        DetailRow('Возраст', '${animal.age} г.'),
        DetailRow('Цена', '${animal.price.toStringAsFixed(0)} ₽'),
        DetailRow('Количество', '${animal.quantity} шт.'),
        DetailRow('Поставщик', _supplierName(animal.supplierId)),
        DetailRow('Категории', _categoryNames(animal.categoryIds)),
        DetailRow('Ветеринары', _vetNames(animal.vetIds)),
        DetailRow(
          'Описание',
          animal.description.isEmpty ? '—' : animal.description,
        ),
      ],
      onEdit: () => context.push('/animals/${animal.id}/edit'),
      onDelete: () async {
        final repository = context.read<AnimalRepository>();
        final notifier = context.read<AnimalListNotifier>();
        await repository.softDelete(animal.id);
        await notifier.load();
        _close();
      },
      onRestore: () async {
        final repository = context.read<AnimalRepository>();
        final notifier = context.read<AnimalListNotifier>();
        await repository.restore(animal.id);
        await notifier.load();
        await _load();
      },
      onHardDelete: () async {
        final repository = context.read<AnimalRepository>();
        final notifier = context.read<AnimalListNotifier>();
        await repository.hardDelete(animal.id);
        await notifier.load();
        _close();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/category.dart' as model;
import '../models/list_query.dart';
import '../models/vet.dart';
import '../repositories/category_repository.dart';
import '../repositories/vet_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/detail_scaffold.dart';

class VetDetailScreen extends StatefulWidget {
  final int id;

  const VetDetailScreen({super.key, required this.id});

  @override
  State<VetDetailScreen> createState() => _VetDetailScreenState();
}

class _VetDetailScreenState extends State<VetDetailScreen> {
  Vet? _vet;
  List<model.Category> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vetRepository = context.read<VetRepository>();
    final categoryRepository = context.read<CategoryRepository>();
    final vet = await vetRepository.findById(widget.id);
    final categories = await categoryRepository.find(const ListQuery(size: 1000));
    if (!mounted) return;
    setState(() {
      _vet = vet;
      _categories = categories.items;
      _loading = false;
    });
  }

  String _categoryName(int id) {
    for (final category in _categories) {
      if (category.id == id) return category.name;
    }
    return '—';
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/vets');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка ветеринара')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final vet = _vet;
    if (vet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка ветеринара')),
        body: const Center(child: Text('Ветеринар не найден')),
      );
    }

    return DetailScaffold(
      title: 'Карточка ветеринара',
      currentPath: '/vets',
      isDeleted: vet.isDeleted,
      rows: [
        DetailRow('ФИО', vet.fullName),
        DetailRow(
          'Специализация',
          _categoryName(vet.specializationCategoryId),
        ),
        DetailRow('Телефон', vet.phone),
        DetailRow('Почта', vet.email),
      ],
      onEdit: () => context.push('/vets/${vet.id}/edit'),
      onDelete: () async {
        final repository = context.read<VetRepository>();
        final notifier = context.read<EntityListNotifier<Vet>>();
        await repository.softDelete(vet.id);
        await notifier.load();
        _close();
      },
      onRestore: () async {
        final repository = context.read<VetRepository>();
        final notifier = context.read<EntityListNotifier<Vet>>();
        await repository.restore(vet.id);
        await notifier.load();
        await _load();
      },
      onHardDelete: () async {
        final repository = context.read<VetRepository>();
        final notifier = context.read<EntityListNotifier<Vet>>();
        await repository.hardDelete(vet.id);
        await notifier.load();
        _close();
      },
    );
  }
}

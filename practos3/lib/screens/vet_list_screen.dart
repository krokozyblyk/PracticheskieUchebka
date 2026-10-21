import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/category.dart' as model;
import '../models/list_query.dart';
import '../models/vet.dart';
import '../repositories/category_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_scaffold.dart';

class VetListScreen extends StatefulWidget {
  const VetListScreen({super.key});

  @override
  State<VetListScreen> createState() => _VetListScreenState();
}

class _VetListScreenState extends State<VetListScreen> {
  List<model.Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await context
        .read<CategoryRepository>()
        .find(const ListQuery(size: 1000));
    if (!mounted) return;
    setState(() => _categories = result.items);
  }

  String _categoryName(int id) {
    for (final category in _categories) {
      if (category.id == id) return category.name;
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<EntityListNotifier<Vet>>();

    return ListScaffold<Vet>(
      title: 'Ветеринары',
      currentPath: '/vets',
      controller: notifier,
      idOf: (vet) => vet.id,
      isDeleted: (vet) => vet.isDeleted,
      createLabel: 'Добавить ветеринара',
      onCreate: (context) => context.push('/vets/new'),
      onOpen: (context, vet) => context.push('/vets/${vet.id}'),
      onEdit: (context, vet) => context.push('/vets/${vet.id}/edit'),
      columns: [
        TableColumnSpec(
          label: 'ФИО',
          sortField: 'fullName',
          build: (vet) => Text(vet.fullName),
        ),
        TableColumnSpec(
          label: 'Специализация',
          build: (vet) => Text(_categoryName(vet.specializationCategoryId)),
        ),
        TableColumnSpec(
          label: 'Телефон',
          build: (vet) => Text(vet.phone),
        ),
        TableColumnSpec(
          label: 'Почта',
          build: (vet) => Text(vet.email),
        ),
      ],
    );
  }
}

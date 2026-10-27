import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_scaffold.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EntityListNotifier<Category>>().load();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<EntityListNotifier<Category>>();

    return ListScaffold<Category>(
      title: 'Категории',
      currentPath: '/categories',
      controller: notifier,
      idOf: (category) => category.id,
      isDeleted: (category) => category.isDeleted,
      createLabel: 'Добавить категорию',
      onCreate: (context) => context.push('/categories/new'),
      onOpen: (context, category) =>
          context.push('/categories/${category.id}'),
      onEdit: (context, category) =>
          context.push('/categories/${category.id}/edit'),
      columns: [
        TableColumnSpec(
          label: 'Название',
          sortField: 'name',
          build: (category) => Text(category.name),
        ),
        TableColumnSpec(
          label: 'Раздел',
          sortField: 'section',
          build: (category) => Text(category.section),
        ),
      ],
    );
  }
}

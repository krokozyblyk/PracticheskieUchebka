import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/list_filters.dart';
import '../logic/list_url.dart';
import '../models/category.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_scaffold.dart';
import '../widgets/query_url_sync.dart';

class CategoryListScreen extends StatefulWidget {
  final Map<String, String> queryParameters;

  const CategoryListScreen({super.key, this.queryParameters = const {}});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EntityListNotifier<Category>>().applyQuery(
      listQueryFromParams(widget.queryParameters, defaultSort: 'name'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<EntityListNotifier<Category>>();

    return QueryUrlSync(
      path: '/categories',
      listenable: notifier,
      queryOf: () => notifier.query,
      child: ListScaffold<Category>(
        title: 'Категории',
        currentPath: '/categories',
        controller: notifier,
        idOf: (category) => category.id,
        isDeleted: (category) => category.isDeleted,
        filters: categoryFilterSpecs,
        onFiltersChanged: notifier.applyFilters,
        queryOf: () => notifier.query,
        createLabel: 'Создать категорию',
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
      ),
    );
  }
}

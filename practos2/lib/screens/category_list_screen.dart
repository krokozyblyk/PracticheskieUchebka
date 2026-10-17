import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../state/category_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/search_field.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<CategoryListNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        actions: [
          IconButton(
            tooltip: 'К животным',
            icon: const Icon(Icons.pets_outlined),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              initialValue: notifier.search,
              onChanged: notifier.setSearch,
            ),
            const SizedBox(height: 12),
            FilterChip(
              label: const Text('Показывать удалённые'),
              selected: notifier.includeDeleted,
              onSelected: notifier.setIncludeDeleted,
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(context, notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CategoryListNotifier notifier) {
    switch (notifier.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 12),
              Text(notifier.error ?? 'Ошибка'),
            ],
          ),
        );
      case LoadStatus.success:
        if (notifier.result.items.isEmpty) {
          return const Center(child: Text('Ничего не найдено'));
        }
        final result = notifier.result;
        return Column(
          children: [
            Expanded(
              child: EntityTable<Category>(
                items: result.items,
                idOf: (c) => c.id,
                sortField: notifier.sortField,
                sortAscending: notifier.sortAscending,
                onSort: notifier.sortBy,
                columns: [
                  TableColumnSpec(
                    label: 'Название',
                    sortField: 'name',
                    build: (c) => Text(c.name),
                  ),
                  TableColumnSpec(
                    label: 'Раздел',
                    sortField: 'section',
                    build: (c) => Text(c.section),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            PaginationBar(
              page: result.page,
              totalPages: result.totalPages,
              total: result.total,
              size: result.size,
              onPage: notifier.goToPage,
              onSize: notifier.setSize,
            ),
          ],
        );
    }
  }
}

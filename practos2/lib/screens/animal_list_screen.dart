import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/category.dart' as model;
import '../models/supplier.dart';
import '../repositories/category_repository.dart';
import '../state/animal_list_notifier.dart';
import '../widgets/animal_card.dart';
import '../widgets/entity_table.dart';
import '../widgets/filter_panel.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/search_field.dart';

class AnimalListScreen extends StatefulWidget {
  final Map<String, String> queryParameters;

  const AnimalListScreen({super.key, this.queryParameters = const {}});

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  List<model.Category> _categories = [];
  Map<String, String> _lastApplied = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _syncQuery();
  }

  @override
  void didUpdateWidget(covariant AnimalListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncQuery();
  }

  void _syncQuery() {
    if (mapEquals(_lastApplied, widget.queryParameters)) return;
    _lastApplied = widget.queryParameters;
    if (widget.queryParameters.isEmpty) {
      context.read<AnimalListNotifier>().applyQuery(const AnimalQuery());
      return;
    }
    final query = AnimalQuery(
      search: widget.queryParameters['search'] ?? '',
      categoryId: _parseInt(widget.queryParameters['categoryId']),
      supplierId: _parseInt(widget.queryParameters['supplierId']),
      priceFrom: double.tryParse(widget.queryParameters['priceFrom'] ?? ''),
      priceTo: double.tryParse(widget.queryParameters['priceTo'] ?? ''),
      sortField: widget.queryParameters['sortField'] ?? 'name',
      sortAscending: widget.queryParameters['sortAscending'] != 'false',
      page: _parseInt(widget.queryParameters['page']) ?? 1,
      size: _parseInt(widget.queryParameters['size']) ?? 10,
      includeDeleted: widget.queryParameters['includeDeleted'] == 'true',
    );
    context.read<AnimalListNotifier>().applyQuery(query);
  }

  Future<void> _loadCategories() async {
    final repo = context.read<CategoryRepository>();
    final result = await repo.find(
      search: '',
      sortField: 'name',
      sortAscending: true,
      page: 1,
      size: 100,
      includeDeleted: false,
    );
    if (!mounted) return;
    setState(() => _categories = result.items);
  }

  int? _parseInt(String? value) => int.tryParse(value ?? '');

  void _updateUrl(AnimalQuery query) {
    final params = <String, String>{
      if (query.search.isNotEmpty) 'search': query.search,
      if (query.categoryId != null) 'categoryId': '${query.categoryId}',
      if (query.supplierId != null) 'supplierId': '${query.supplierId}',
      if (query.priceFrom != null) 'priceFrom': '${query.priceFrom}',
      if (query.priceTo != null) 'priceTo': '${query.priceTo}',
      if (query.sortField != 'name') 'sortField': query.sortField,
      if (!query.sortAscending) 'sortAscending': 'false',
      if (query.page != 1) 'page': '${query.page}',
      if (query.size != 10) 'size': '${query.size}',
      if (query.includeDeleted) 'includeDeleted': 'true',
    };
    final uri = Uri(path: '/animals', queryParameters: params.isEmpty ? null : params);
    context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AnimalListNotifier>();
    final query = notifier.query;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Зоомагазин'),
        actions: [
          IconButton(
            tooltip: 'Категории',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => context.go('/categories'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              initialValue: query.search,
              onChanged: (value) => _applyQuery(
                context,
                query.copyWith(search: value),
              ),
            ),
            const SizedBox(height: 12),
            FilterPanel(
              categoryId: query.categoryId,
              supplierId: query.supplierId,
              priceFrom: query.priceFrom?.toString(),
              priceTo: query.priceTo?.toString(),
              includeDeleted: query.includeDeleted,
              categoryItems: _categories
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              supplierItems: suppliers
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ))
                  .toList(),
              onCategory: (value) => _applyQuery(
                context,
                query.copyWith(categoryId: value),
              ),
              onSupplier: (value) => _applyQuery(
                context,
                query.copyWith(supplierId: value),
              ),
              onPriceFrom: (value) => _applyQuery(
                context,
                query.copyWith(
                  priceFrom: double.tryParse(value ?? ''),
                ),
              ),
              onPriceTo: (value) => _applyQuery(
                context,
                query.copyWith(
                  priceTo: double.tryParse(value ?? ''),
                ),
              ),
              onIncludeDeleted: (value) => _applyQuery(
                context,
                query.copyWith(includeDeleted: value),
              ),
              onReset: () => _applyQuery(context, const AnimalQuery()),
            ),
            const SizedBox(height: 12),
            _buildToolbar(context, notifier),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(context, notifier)),
          ],
        ),
      ),
    );
  }

  void _applyQuery(BuildContext context, AnimalQuery next) {
    _updateUrl(next);
    context.read<AnimalListNotifier>().applyQuery(next);
  }

  Widget _buildToolbar(BuildContext context, AnimalListNotifier notifier) {
    return Row(
      children: [
        if (notifier.hasSelection)
          FilledButton.icon(
            onPressed: () => _confirmDelete(context, notifier),
            icon: const Icon(Icons.delete_outline),
            label: Text('Удалить выбранные (${notifier.selected.length})'),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AnimalListNotifier notifier) {
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
        return _buildContent(context, notifier);
    }
  }

  Widget _buildContent(BuildContext context, AnimalListNotifier notifier) {
    final query = notifier.query;
    final result = notifier.result;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return Column(
          children: [
            Expanded(
              child: isNarrow
                  ? ListView.builder(
                      itemCount: result.items.length,
                      itemBuilder: (context, index) {
                        final animal = result.items[index];
                        return InkWell(
                          onTap: () => context.go('/animals/${animal.id}'),
                          child: AnimalCard(animal: animal),
                        );
                      },
                    )
                  : _buildTable(context, notifier),
            ),
            const SizedBox(height: 8),
            PaginationBar(
              page: result.page,
              totalPages: result.totalPages,
              total: result.total,
              size: result.size,
              onPage: (page) =>
                  _applyQuery(context, query.copyWith(page: page)),
              onSize: (size) =>
                  _applyQuery(context, query.copyWith(size: size)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, AnimalListNotifier notifier) {
    final query = notifier.query;
    return EntityTable<Animal>(
      items: notifier.result.items,
      idOf: (a) => a.id,
      selected: notifier.selected,
      onToggleSelect: notifier.toggleSelection,
      onToggleSelectAll: (value) {
        for (final a in notifier.result.items) {
          if (notifier.selected.contains(a.id) != value) {
            notifier.toggleSelection(a.id);
          }
        }
      },
      sortField: query.sortField,
      sortAscending: query.sortAscending,
      onSort: (field) => _applyQuery(
        context,
        query.copyWith(
          sortField: field,
          sortAscending: field == query.sortField
              ? !query.sortAscending
              : true,
        ),
      ),
      columns: [
        TableColumnSpec(
          label: 'Название',
          sortField: 'name',
          build: (a) => Text(a.name),
        ),
        TableColumnSpec(
          label: 'Вид',
          build: (a) => Text(a.species),
        ),
        TableColumnSpec(
          label: 'Возраст',
          sortField: 'age',
          numeric: true,
          build: (a) => Text('${a.age}'),
        ),
        TableColumnSpec(
          label: 'Цена',
          sortField: 'price',
          numeric: true,
          build: (a) => Text('${a.price.toStringAsFixed(0)} ₽'),
        ),
        TableColumnSpec(
          label: 'Поставщик',
          build: (a) => Text(supplierName(a.supplierId)),
        ),
        TableColumnSpec(
          label: 'В наличии',
          sortField: 'quantity',
          numeric: true,
          build: (a) => Text('${a.quantity}'),
        ),
      ],
      actions: (a) => [
        IconButton(
          icon: const Icon(Icons.visibility_outlined),
          tooltip: 'Открыть',
          onPressed: () => context.go('/animals/${a.id}'),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AnimalListNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить выбранные?'),
        content: Text('Будет удалено записей: ${notifier.selected.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await notifier.deleteSelected();
    }
  }
}

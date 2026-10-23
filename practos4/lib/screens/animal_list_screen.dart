import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/category.dart' as model;
import '../models/list_query.dart';
import '../models/supplier.dart';
import '../models/vet.dart';
import '../repositories/category_repository.dart';
import '../repositories/supplier_repository.dart';
import '../repositories/vet_repository.dart';
import '../state/animal_list_notifier.dart';
import '../state/load_status.dart';
import '../widgets/animal_card.dart';
import '../widgets/api_error.dart';
import '../widgets/entity_table.dart';
import '../widgets/filter_panel.dart';
import '../widgets/nav_drawer.dart';
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
  List<Supplier> _suppliers = [];
  List<Vet> _vets = [];
  Map<String, String> _lastApplied = {};

  @override
  void initState() {
    super.initState();
    _loadLookups();
    _syncQuery();
  }

  @override
  void didUpdateWidget(covariant AnimalListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncQuery();
  }

  Future<void> _loadLookups() async {
    final categoryRepository = context.read<CategoryRepository>();
    final supplierRepository = context.read<SupplierRepository>();
    final vetRepository = context.read<VetRepository>();
    final categories =
        await categoryRepository.find(const ListQuery(size: 1000));
    final suppliers =
        await supplierRepository.find(const ListQuery(size: 1000));
    final vets = await vetRepository.find(const ListQuery(size: 1000));
    if (!mounted) return;
    setState(() {
      _categories = categories.items;
      _suppliers = suppliers.items;
      _vets = vets.items;
    });
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
      vetId: _parseInt(widget.queryParameters['vetId']),
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

  int? _parseInt(String? value) => int.tryParse(value ?? '');

  void _updateUrl(AnimalQuery query) {
    final params = <String, String>{
      if (query.search.isNotEmpty) 'search': query.search,
      if (query.categoryId != null) 'categoryId': '${query.categoryId}',
      if (query.supplierId != null) 'supplierId': '${query.supplierId}',
      if (query.vetId != null) 'vetId': '${query.vetId}',
      if (query.priceFrom != null) 'priceFrom': '${query.priceFrom}',
      if (query.priceTo != null) 'priceTo': '${query.priceTo}',
      if (query.sortField != 'name') 'sortField': query.sortField,
      if (!query.sortAscending) 'sortAscending': 'false',
      if (query.page != 1) 'page': '${query.page}',
      if (query.size != 10) 'size': '${query.size}',
      if (query.includeDeleted) 'includeDeleted': 'true',
    };
    final uri = Uri(
      path: '/animals',
      queryParameters: params.isEmpty ? null : params,
    );
    context.go(uri.toString());
  }

  void _applyQuery(AnimalQuery next) {
    _updateUrl(next);
    context.read<AnimalListNotifier>().applyQuery(next);
  }

  String supplierName(int id) {
    for (final supplier in _suppliers) {
      if (supplier.id == id) return supplier.name;
    }
    return '—';
  }

  String vetName(int id) {
    for (final vet in _vets) {
      if (vet.id == id) return vet.fullName;
    }
    return '—';
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) showApiError(context, error);
    }
  }

  Future<bool> _ask(
    String title,
    String content,
    String confirmLabel,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AnimalListNotifier>();
    final query = notifier.query;

    return Scaffold(
      appBar: navAppBar(context, 'Зоомагазин'),
      drawer: const NavDrawer(currentPath: '/animals'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchField(
              initialValue: query.search,
              onChanged: (value) => _applyQuery(
                query.copyWith(search: value),
              ),
            ),
            const SizedBox(height: 12),
            FilterPanel(
              categoryId: query.categoryId,
              supplierId: query.supplierId,
              vetId: query.vetId,
              priceFrom: query.priceFrom?.toString(),
              priceTo: query.priceTo?.toString(),
              includeDeleted: query.includeDeleted,
              categoryItems: _categories
                  .map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              supplierItems: _suppliers
                  .map((s) => DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(s.name),
                      ))
                  .toList(),
              vetItems: _vets
                  .map((v) => DropdownMenuItem<int>(
                        value: v.id,
                        child: Text(v.fullName),
                      ))
                  .toList(),
              onCategory: (value) => _applyQuery(
                query.copyWith(categoryId: value),
              ),
              onSupplier: (value) => _applyQuery(
                query.copyWith(supplierId: value),
              ),
              onVet: (value) => _applyQuery(
                query.copyWith(vetId: value),
              ),
              onPriceFrom: (value) => _applyQuery(
                query.copyWith(priceFrom: double.tryParse(value ?? '')),
              ),
              onPriceTo: (value) => _applyQuery(
                query.copyWith(priceTo: double.tryParse(value ?? '')),
              ),
              onIncludeDeleted: (value) => _applyQuery(
                query.copyWith(includeDeleted: value),
              ),
              onReset: () => _applyQuery(const AnimalQuery()),
            ),
            const SizedBox(height: 12),
            _buildToolbar(notifier),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(notifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(AnimalListNotifier notifier) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: () => context.push('/animals/new'),
          icon: const Icon(Icons.add),
          label: const Text('Добавить животное'),
        ),
        if (notifier.hasSelection) ...[
          OutlinedButton.icon(
            onPressed: () async {
              if (await _ask(
                'Удалить выбранные?',
                'Будет помечено на удаление: ${notifier.selected.length}',
                'Удалить',
              )) {
                if (!mounted) return;
                await _run(context, notifier.deleteSelected);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: Text('Удалить выбранные (${notifier.selected.length})'),
          ),
          if (notifier.includeDeleted) ...[
            TextButton.icon(
              onPressed: () async {
                if (await _ask(
                  'Удалить навсегда?',
                  'Записи будут удалены физически: '
                      '${notifier.selected.length}',
                  'Удалить',
                )) {
                  if (!mounted) return;
                  await _run(context, notifier.hardDeleteSelected);
                }
              },
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(
                'Удалить навсегда (${notifier.selected.length})',
              ),
            ),
            TextButton.icon(
              onPressed: () => _run(context, notifier.restoreSelected),
              icon: const Icon(Icons.restore),
              label: Text('Восстановить (${notifier.selected.length})'),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildBody(AnimalListNotifier notifier) {
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: notifier.load,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        );
      case LoadStatus.success:
        if (notifier.result.items.isEmpty) {
          return const Center(child: Text('Ничего не найдено'));
        }
        return _buildContent(notifier);
    }
  }

  Widget _buildContent(AnimalListNotifier notifier) {
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
                          onTap: () => context.push('/animals/${animal.id}'),
                          child: Row(
                            children: [
                              Expanded(
                                child: AnimalCard(
                                  animal: animal,
                                  supplierName:
                                      supplierName(animal.supplierId),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Изменить',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () =>
                                    context.push('/animals/${animal.id}/edit'),
                              ),
                              IconButton(
                                tooltip: 'Удалить',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  if (await _ask(
                                    'Удалить запись?',
                                    'Запись будет помечена на удаление.',
                                    'Удалить',
                                  )) {
                                    if (!context.mounted) return;
                                    await _run(
                                      context,
                                      () => notifier.deleteOne(animal.id),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
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
                  _applyQuery(query.copyWith(page: page)),
              onSize: (size) =>
                  _applyQuery(query.copyWith(size: size)),
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
          label: 'Артикул',
          sortField: 'sku',
          build: (a) => Text(a.sku),
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
          onPressed: () => context.push('/animals/${a.id}'),
        ),
        if (a.isDeleted) ...[
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Восстановить',
            onPressed: () => _run(context, () => notifier.restoreOne(a.id)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            tooltip: 'Удалить навсегда',
            onPressed: () async {
              if (await _ask(
                'Удалить навсегда?',
                'Запись будет удалена физически.',
                'Удалить',
              )) {
                if (!context.mounted) return;
                await _run(context, () => notifier.hardDeleteOne(a.id));
              }
            },
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Изменить',
            onPressed: () => context.push('/animals/${a.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить',
            onPressed: () async {
              if (await _ask(
                'Удалить запись?',
                'Запись будет помечена на удаление.',
                'Удалить',
              )) {
                if (!context.mounted) return;
                await _run(context, () => notifier.deleteOne(a.id));
              }
            },
          ),
        ],
      ],
    );
  }
}

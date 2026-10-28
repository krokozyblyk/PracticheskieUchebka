import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/permissions.dart';
import '../state/auth_notifier.dart';
import '../state/list_controller.dart';
import '../state/load_status.dart';
import 'api_error.dart';
import 'app_navigation.dart';
import 'entity_table.dart';
import 'pagination_bar.dart';
import 'search_field.dart';

class ListScaffold<T> extends StatelessWidget {
  final String title;
  final String currentPath;
  final PagedListController<T> controller;
  final List<TableColumnSpec<T>> columns;
  final int Function(T item) idOf;
  final bool Function(T item) isDeleted;
  final void Function(BuildContext context) onCreate;
  final void Function(BuildContext context, T item) onOpen;
  final void Function(BuildContext context, T item) onEdit;
  final Future<int> Function(List<int> ids)? linkedCount;
  final String createLabel;
  final String emptyText;

  const ListScaffold({
    super.key,
    required this.title,
    required this.currentPath,
    required this.controller,
    required this.columns,
    required this.idOf,
    required this.isDeleted,
    required this.onCreate,
    required this.onOpen,
    required this.onEdit,
    this.linkedCount,
    this.createLabel = 'Добавить',
    this.emptyText = 'Ничего не найдено',
  });

  Future<bool> _ask(
    BuildContext context,
    String title,
    String content,
    String confirmLabel,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        constraints: const BoxConstraints(maxWidth: 480),
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

  Future<bool> _checkLinked(BuildContext context, List<int> ids) async {
    if (linkedCount == null) return true;
    final linked = await linkedCount!(ids);
    if (linked > 0 && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          constraints: const BoxConstraints(maxWidth: 480),
          title: const Text('Удаление невозможно'),
          content: Text(
            'На эти записи ссылаются связанные данные. '
            'Связанных записей: $linked.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final ids = controller.selected.toList();
    if (ids.isEmpty) return;
    if (!await _checkLinked(context, ids)) return;
    if (!context.mounted) return;
    if (await _ask(
      context,
      'Удалить выбранные?',
      'Будет помечено на удаление: ${ids.length}',
      'Удалить',
    )) {
      if (!context.mounted) return;
      await _run(context, controller.deleteSelected);
    }
  }

  Future<void> _hardDeleteSelected(BuildContext context) async {
    final ids = controller.selected.toList();
    if (ids.isEmpty) return;
    if (!await _checkLinked(context, ids)) return;
    if (!context.mounted) return;
    if (await _ask(
      context,
      'Удалить навсегда?',
      'Записи будут удалены физически: ${ids.length}',
      'Удалить',
    )) {
      if (!context.mounted) return;
      await _run(context, controller.hardDeleteSelected);
    }
  }

  Future<void> _restoreSelected(BuildContext context) async {
    final ids = controller.selected.toList();
    if (ids.isEmpty) return;
    await _run(context, controller.restoreSelected);
  }

  Future<void> _deleteOne(BuildContext context, T item) async {
    final id = idOf(item);
    if (!await _checkLinked(context, [id])) return;
    if (!context.mounted) return;
    if (await _ask(
      context,
      'Удалить запись?',
      'Запись будет помечена на удаление.',
      'Удалить',
    )) {
      if (!context.mounted) return;
      await _run(context, () => controller.deleteOne(id));
    }
  }

  Future<void> _hardDeleteOne(BuildContext context, T item) async {
    final id = idOf(item);
    if (!await _checkLinked(context, [id])) return;
    if (!context.mounted) return;
    if (await _ask(
      context,
      'Удалить навсегда?',
      'Запись будет удалена физически.',
      'Удалить',
    )) {
      if (!context.mounted) return;
      await _run(context, () => controller.hardDeleteOne(id));
    }
  }

  Future<void> _restoreOne(BuildContext context, T item) async {
    await _run(context, () => controller.restoreOne(idOf(item)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final canManage = auth.can(Permission.manageCatalog);
    final canDelete = auth.can(Permission.deleteSoft);
    final canAdmin = auth.can(Permission.deleteHard);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AppScaffold(
          title: title,
          currentPath: currentPath,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchField(
                  initialValue: controller.search,
                  onChanged: controller.setSearch,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (canDelete || canAdmin)
                      FilterChip(
                        label: const Text('Показывать удалённые'),
                        selected: controller.includeDeleted,
                        onSelected: controller.setIncludeDeleted,
                      ),
                    if (canManage)
                      FilledButton.icon(
                        onPressed: () => onCreate(context),
                        icon: const Icon(Icons.add),
                        label: Text(createLabel),
                      ),
                    if (controller.hasSelection) ...[
                      if (canDelete)
                        OutlinedButton.icon(
                          onPressed: () => _deleteSelected(context),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(
                            'Удалить выбранные (${controller.selected.length})',
                          ),
                        ),
                      if (canAdmin && controller.includeDeleted) ...[
                        TextButton.icon(
                          onPressed: () => _hardDeleteSelected(context),
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: Text(
                            'Удалить навсегда (${controller.selected.length})',
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _restoreSelected(context),
                          icon: const Icon(Icons.restore),
                          label: Text(
                            'Восстановить (${controller.selected.length})',
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final canManage = auth.can(Permission.manageCatalog);
    final canDelete = auth.can(Permission.deleteSoft);
    final canAdmin = auth.can(Permission.deleteHard);

    switch (controller.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(controller.error ?? 'Ошибка', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.load,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        );
      case LoadStatus.success:
        final result = controller.result;
        if (result.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 48,
                  color: Color(0xFF5F6368),
                ),
                const SizedBox(height: 10),
                Text(emptyText),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: EntityTable<T>(
                items: result.items,
                idOf: idOf,
                selected: controller.selected,
                sortField: controller.sortField,
                sortAscending: controller.sortAscending,
                onToggleSelect: controller.toggleSelection,
                onToggleSelectAll: (value) {
                  for (final item in result.items) {
                    final id = idOf(item);
                    if (controller.selected.contains(id) != value) {
                      controller.toggleSelection(id);
                    }
                  }
                },
                onSort: controller.sortBy,
                columns: columns,
                actions: (item) => [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    tooltip: 'Открыть',
                    onPressed: () => onOpen(context, item),
                  ),
                  if (isDeleted(item)) ...[
                    if (canAdmin) ...[
                      IconButton(
                        icon: const Icon(Icons.restore),
                        tooltip: 'Восстановить',
                        onPressed: () => _restoreOne(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever_outlined),
                        tooltip: 'Удалить навсегда',
                        onPressed: () => _hardDeleteOne(context, item),
                      ),
                    ],
                  ] else ...[
                    if (canManage)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Изменить',
                        onPressed: () => onEdit(context, item),
                      ),
                    if (canDelete)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Удалить',
                        onPressed: () => _deleteOne(context, item),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            PaginationBar(
              page: result.page,
              totalPages: result.totalPages,
              total: result.total,
              size: result.size,
              onPage: controller.goToPage,
              onSize: controller.setSize,
            ),
          ],
        );
    }
  }
}

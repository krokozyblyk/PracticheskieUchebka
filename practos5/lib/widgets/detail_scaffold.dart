import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/permissions.dart';
import '../state/auth_notifier.dart';
import 'api_error.dart';
import 'nav_drawer.dart';

class DetailRow {
  final String label;
  final String value;

  const DetailRow(this.label, this.value);
}

class DetailScaffold extends StatelessWidget {
  final String title;
  final String currentPath;
  final List<DetailRow> rows;
  final bool isDeleted;
  final VoidCallback? onEdit;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onRestore;
  final Future<void> Function()? onHardDelete;
  final Widget? extra;

  const DetailScaffold({
    super.key,
    required this.title,
    required this.currentPath,
    required this.rows,
    this.isDeleted = false,
    this.onEdit,
    this.onDelete,
    this.onRestore,
    this.onHardDelete,
    this.extra,
  });

  Future<bool> _confirm(
    BuildContext context,
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final canManage = auth.can(Permission.manageCatalog);
    final canDelete = auth.can(Permission.deleteSoft);
    final canAdmin = auth.can(Permission.deleteHard);

    return Scaffold(
      appBar: navAppBar(context, title),
      drawer: NavDrawer(currentPath: currentPath),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDeleted)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Запись помечена на удаление'),
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (final row in rows)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 190,
                                    child: Text(
                                      row.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Text(row.value)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (extra != null) ...[
                    const SizedBox(height: 12),
                    extra!,
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (onEdit != null && !isDeleted && canManage)
                        FilledButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Изменить'),
                        ),
                      if (onDelete != null && !isDeleted && canDelete)
                        OutlinedButton.icon(
                          onPressed: () async {
                            if (await _confirm(
                              context,
                              'Удалить запись?',
                              'Запись будет помечена на удаление.',
                              'Удалить',
                            )) {
                              if (!context.mounted) return;
                              await _run(context, onDelete!);
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Удалить'),
                        ),
                      if (onRestore != null && isDeleted && canAdmin)
                        FilledButton.icon(
                          onPressed: () => _run(context, onRestore!),
                          icon: const Icon(Icons.restore),
                          label: const Text('Восстановить'),
                        ),
                      if (onHardDelete != null && isDeleted && canAdmin)
                        OutlinedButton.icon(
                          onPressed: () async {
                            if (await _confirm(
                              context,
                              'Удалить навсегда?',
                              'Запись будет удалена физически.',
                              'Удалить',
                            )) {
                              if (!context.mounted) return;
                              await _run(context, onHardDelete!);
                            }
                          },
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: const Text('Удалить навсегда'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

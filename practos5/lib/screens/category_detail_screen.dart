import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../repositories/category_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/detail_scaffold.dart';

class CategoryDetailScreen extends StatefulWidget {
  final int id;

  const CategoryDetailScreen({super.key, required this.id});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  Category? _category;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final category =
        await context.read<CategoryRepository>().findById(widget.id);
    if (!mounted) return;
    setState(() {
      _category = category;
      _loading = false;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка категории')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final category = _category;
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка категории')),
        body: const Center(child: Text('Категория не найдена')),
      );
    }

    return DetailScaffold(
      title: 'Карточка категории',
      currentPath: '/categories',
      isDeleted: category.isDeleted,
      rows: [
        DetailRow('Название', category.name),
        DetailRow('Раздел', category.section),
      ],
      onEdit: () => context.push('/categories/${category.id}/edit'),
      onDelete: () async {
        final repository = context.read<CategoryRepository>();
        final notifier = context.read<EntityListNotifier<Category>>();
        await repository.softDelete(category.id);
        await notifier.load();
        _close();
      },
      onRestore: () async {
        final repository = context.read<CategoryRepository>();
        final notifier = context.read<EntityListNotifier<Category>>();
        await repository.restore(category.id);
        await notifier.load();
        await _load();
      },
      onHardDelete: () async {
        final repository = context.read<CategoryRepository>();
        final notifier = context.read<EntityListNotifier<Category>>();
        await repository.hardDelete(category.id);
        await notifier.load();
        _close();
      },
    );
  }
}

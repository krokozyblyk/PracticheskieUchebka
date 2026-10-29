import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/permissions.dart';

import '../models/review.dart';
import '../repositories/review_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/detail_scaffold.dart';

class ReviewDetailScreen extends StatefulWidget {
  final int id;

  const ReviewDetailScreen({super.key, required this.id});

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  Review? _review;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final review = await context.read<ReviewRepository>().findById(widget.id);
    if (!mounted) return;
    setState(() {
      _review = review;
      _loading = false;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/reviews');
    }
  }

  String _date(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Отзыв')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final review = _review;
    if (review == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Отзыв')),
        body: const Center(child: Text('Отзыв не найден')),
      );
    }
    return DetailScaffold(
      title: 'Отзыв №${review.id}',
      currentPath: '/reviews',
      isDeleted: review.isDeleted,
      managePermission: Permission.manageReviews,
      deletePermission: Permission.manageReviews,
      rows: [
        DetailRow('Животное', review.animalName),
        DetailRow('Оценка', '${review.rating} из 5'),
        DetailRow('Текст', review.text.isEmpty ? '—' : review.text),
        DetailRow('Автор', review.userName),
        DetailRow('Дата', _date(review.createdAt)),
      ],
      onEdit: () => context.push('/reviews/${review.id}/edit'),
      onDelete: () async {
        final repository = context.read<ReviewRepository>();
        final notifier = context.read<EntityListNotifier<Review>>();
        await repository.softDelete(review.id);
        await notifier.load();
        if (!mounted) return;
        _close();
      },
      onRestore: () async {
        final repository = context.read<ReviewRepository>();
        final notifier = context.read<EntityListNotifier<Review>>();
        await repository.restore(review.id);
        await notifier.load();
        if (!mounted) return;
        await _load();
      },
      onHardDelete: () async {
        final repository = context.read<ReviewRepository>();
        final notifier = context.read<EntityListNotifier<Review>>();
        await repository.hardDelete(review.id);
        await notifier.load();
        if (!mounted) return;
        _close();
      },
    );
  }
}

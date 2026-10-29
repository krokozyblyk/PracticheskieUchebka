import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/list_filters.dart';
import '../logic/list_url.dart';
import '../logic/permissions.dart';
import '../models/review.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_scaffold.dart';
import '../widgets/query_url_sync.dart';

class ReviewListScreen extends StatefulWidget {
  final Map<String, String> queryParameters;

  const ReviewListScreen({super.key, this.queryParameters = const {}});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EntityListNotifier<Review>>().applyQuery(
      listQueryFromParams(widget.queryParameters, defaultSort: 'createdAt'),
    );
  }

  String _date(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<EntityListNotifier<Review>>();
    return QueryUrlSync(
      path: '/reviews',
      listenable: notifier,
      queryOf: () => notifier.query,
      child: ListScaffold<Review>(
        title: 'Отзывы',
        currentPath: '/reviews',
        controller: notifier,
        idOf: (review) => review.id,
        isDeleted: (review) => review.isDeleted,
        filters: reviewFilterSpecs,
        onFiltersChanged: notifier.applyFilters,
        queryOf: () => notifier.query,
        createLabel: 'Оставить отзыв',
        managePermission: Permission.manageReviews,
        deletePermission: Permission.manageReviews,
        onCreate: (context) => context.push('/reviews/new'),
        onOpen: (context, review) => context.push('/reviews/${review.id}'),
        onEdit: (context, review) => context.push('/reviews/${review.id}/edit'),
        columns: [
          TableColumnSpec(
            label: 'Животное',
            build: (review) => Text(review.animalName),
          ),
          TableColumnSpec(
            label: 'Оценка',
            sortField: 'rating',
            build: (review) => Text('${review.rating} / 5'),
          ),
          TableColumnSpec(
            label: 'Текст',
            build: (review) =>
                Text(review.text, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          TableColumnSpec(
            label: 'Автор',
            build: (review) => Text(review.userName),
          ),
          TableColumnSpec(
            label: 'Дата',
            sortField: 'createdAt',
            build: (review) => Text(_date(review.createdAt)),
          ),
        ],
      ),
    );
  }
}

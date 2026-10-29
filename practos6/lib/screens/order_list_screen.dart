import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/list_filters.dart';
import '../logic/list_url.dart';
import '../models/order.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_scaffold.dart';
import '../widgets/query_url_sync.dart';

class OrderListScreen extends StatefulWidget {
  final Map<String, String> queryParameters;

  const OrderListScreen({super.key, this.queryParameters = const {}});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EntityListNotifier<Order>>().applyQuery(
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
    final notifier = context.read<EntityListNotifier<Order>>();
    return QueryUrlSync(
      path: '/orders',
      listenable: notifier,
      queryOf: () => notifier.query,
      child: ListScaffold<Order>(
        title: 'Заказы',
        currentPath: '/orders',
        controller: notifier,
        idOf: (order) => order.id,
        isDeleted: (order) => order.isDeleted,
        filters: orderFilterSpecs,
        onFiltersChanged: notifier.applyFilters,
        queryOf: () => notifier.query,
        createLabel: 'Оформить заказ',
        onCreate: (context) => context.push('/orders/new'),
        onOpen: (context, order) => context.push('/orders/${order.id}'),
        onEdit: (context, order) => context.push('/orders/${order.id}/edit'),
        columns: [
          TableColumnSpec(
            label: 'Покупатель',
            build: (order) => Text(order.customerName),
          ),
          TableColumnSpec(
            label: 'Животное',
            build: (order) => Text(order.animalName),
          ),
          TableColumnSpec(
            label: 'Кол-во',
            numeric: true,
            build: (order) => Text('${order.quantity}'),
          ),
          TableColumnSpec(
            label: 'Сумма',
            sortField: 'total',
            numeric: true,
            build: (order) => Text('${order.total.toStringAsFixed(0)} ₽'),
          ),
          TableColumnSpec(
            label: 'Статус',
            sortField: 'status',
            build: (order) => Text(_status(order.status)),
          ),
          TableColumnSpec(
            label: 'Дата',
            sortField: 'createdAt',
            build: (order) => Text(_date(order.createdAt)),
          ),
        ],
      ),
    );
  }

  String _status(String value) => switch (value) {
    'paid' => 'Оплачен',
    'cancelled' => 'Отменён',
    _ => 'Новый',
  };
}

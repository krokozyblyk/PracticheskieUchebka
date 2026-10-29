import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../repositories/order_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/detail_scaffold.dart';

class OrderDetailScreen extends StatefulWidget {
  final int id;

  const OrderDetailScreen({super.key, required this.id});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final order = await context.read<OrderRepository>().findById(widget.id);
    if (!mounted) return;
    setState(() {
      _order = order;
      _loading = false;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/orders');
    }
  }

  String _date(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.${local.year}';
  }

  String _status(String value) => switch (value) {
    'paid' => 'Оплачен',
    'cancelled' => 'Отменён',
    _ => 'Новый',
  };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Заказ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final order = _order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Заказ')),
        body: const Center(child: Text('Заказ не найден')),
      );
    }
    return DetailScaffold(
      title: 'Заказ №${order.id}',
      currentPath: '/orders',
      isDeleted: order.isDeleted,
      rows: [
        DetailRow('Покупатель', order.customerName),
        DetailRow('Животное', order.animalName),
        DetailRow('Количество', '${order.quantity}'),
        DetailRow('Цена', '${order.unitPrice.toStringAsFixed(0)} ₽'),
        DetailRow('Скидка', '${order.discountPercent}%'),
        DetailRow('Итого', '${order.total.toStringAsFixed(0)} ₽'),
        DetailRow('Статус', _status(order.status)),
        DetailRow('Дата', _date(order.createdAt)),
        DetailRow('Комментарий', order.notes.isEmpty ? '—' : order.notes),
      ],
      onEdit: () => context.push('/orders/${order.id}/edit'),
      onDelete: () async {
        final repository = context.read<OrderRepository>();
        final notifier = context.read<EntityListNotifier<Order>>();
        await repository.softDelete(order.id);
        await notifier.load();
        if (!mounted) return;
        _close();
      },
      onRestore: () async {
        final repository = context.read<OrderRepository>();
        final notifier = context.read<EntityListNotifier<Order>>();
        await repository.restore(order.id);
        await notifier.load();
        if (!mounted) return;
        await _load();
      },
      onHardDelete: () async {
        final repository = context.read<OrderRepository>();
        final notifier = context.read<EntityListNotifier<Order>>();
        await repository.hardDelete(order.id);
        await notifier.load();
        if (!mounted) return;
        _close();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../repositories/customer_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/detail_scaffold.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int id;

  const CustomerDetailScreen({super.key, required this.id});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Customer? _customer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customer =
        await context.read<CustomerRepository>().findById(widget.id);
    if (!mounted) return;
    setState(() {
      _customer = customer;
      _loading = false;
    });
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/customers');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка покупателя')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final customer = _customer;
    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка покупателя')),
        body: const Center(child: Text('Покупатель не найден')),
      );
    }

    final card = customer.loyaltyCard;

    return DetailScaffold(
      title: 'Карточка покупателя',
      currentPath: '/customers',
      isDeleted: customer.isDeleted,
      rows: [
        DetailRow('ФИО', customer.fullName),
        DetailRow('Почта', customer.email),
        DetailRow('Телефон', customer.phone),
        DetailRow('Адрес', customer.address.isEmpty ? '—' : customer.address),
        DetailRow(
          'Карта лояльности',
          card == null ? 'Нет' : '${card.cardNumber} (${card.discountPercent}%)',
        ),
        if (card != null) ...[
          DetailRow('Дата выдачи', _formatDate(card.issuedAt)),
          DetailRow('Статус карты', card.active ? 'Активна' : 'Заблокирована'),
        ],
      ],
      onEdit: () => context.push('/customers/${customer.id}/edit'),
      onDelete: () async {
        final repository = context.read<CustomerRepository>();
        final notifier = context.read<EntityListNotifier<Customer>>();
        await repository.softDelete(customer.id);
        await notifier.load();
        _close();
      },
      onRestore: () async {
        final repository = context.read<CustomerRepository>();
        final notifier = context.read<EntityListNotifier<Customer>>();
        await repository.restore(customer.id);
        await notifier.load();
        await _load();
      },
      onHardDelete: () async {
        final repository = context.read<CustomerRepository>();
        final notifier = context.read<EntityListNotifier<Customer>>();
        await repository.hardDelete(customer.id);
        await notifier.load();
        _close();
      },
    );
  }
}

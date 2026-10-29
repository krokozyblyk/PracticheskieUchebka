import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/list_filters.dart';
import '../logic/list_url.dart';

import '../models/customer.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_scaffold.dart';
import '../widgets/query_url_sync.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key, this.queryParameters = const {}});

  final Map<String, String> queryParameters;

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EntityListNotifier<Customer>>().applyQuery(
      listQueryFromParams(widget.queryParameters, defaultSort: 'fullName'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<EntityListNotifier<Customer>>();

    return QueryUrlSync(
      path: '/customers',
      listenable: notifier,
      queryOf: () => notifier.query,
      child: ListScaffold<Customer>(
        title: 'Покупатели',
        currentPath: '/customers',
        controller: notifier,
        idOf: (customer) => customer.id,
        isDeleted: (customer) => customer.isDeleted,
        filters: customerFilterSpecs,
        onFiltersChanged: notifier.applyFilters,
        queryOf: () => notifier.query,
        createLabel: 'Добавить покупателя',
        onCreate: (context) => context.push('/customers/new'),
        onOpen: (context, customer) =>
            context.push('/customers/${customer.id}'),
        onEdit: (context, customer) =>
            context.push('/customers/${customer.id}/edit'),
        columns: [
          TableColumnSpec(
            label: 'ФИО',
            sortField: 'fullName',
            build: (customer) => Text(customer.fullName),
          ),
          TableColumnSpec(
            label: 'Почта',
            build: (customer) => Text(customer.email),
          ),
          TableColumnSpec(
            label: 'Телефон',
            build: (customer) => Text(customer.phone),
          ),
          TableColumnSpec(
            label: 'Карта лояльности',
            build: (customer) => Text(customer.loyaltyCard?.cardNumber ?? '—'),
          ),
        ],
      ),
    );
  }
}

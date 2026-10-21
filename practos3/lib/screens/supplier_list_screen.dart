import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/supplier.dart';
import '../repositories/animal_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_scaffold.dart';

class SupplierListScreen extends StatelessWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<EntityListNotifier<Supplier>>();
    final animals = context.read<AnimalRepository>();

    return ListScaffold<Supplier>(
      title: 'Поставщики',
      currentPath: '/suppliers',
      controller: notifier,
      idOf: (supplier) => supplier.id,
      isDeleted: (supplier) => supplier.isDeleted,
      createLabel: 'Добавить поставщика',
      onCreate: (context) => context.push('/suppliers/new'),
      onOpen: (context, supplier) =>
          context.push('/suppliers/${supplier.id}'),
      onEdit: (context, supplier) =>
          context.push('/suppliers/${supplier.id}/edit'),
      linkedCount: (ids) async {
        var total = 0;
        for (final id in ids) {
          total += await animals.countBySupplier(id);
        }
        return total;
      },
      columns: [
        TableColumnSpec(
          label: 'Название',
          sortField: 'name',
          build: (supplier) => Text(supplier.name),
        ),
        TableColumnSpec(
          label: 'Контактное лицо',
          sortField: 'contactPerson',
          build: (supplier) => Text(supplier.contactPerson),
        ),
        TableColumnSpec(
          label: 'Телефон',
          build: (supplier) => Text(supplier.phone),
        ),
        TableColumnSpec(
          label: 'Почта',
          build: (supplier) => Text(supplier.email),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/list_filters.dart';
import '../logic/list_url.dart';
import '../models/appointment.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_scaffold.dart';
import '../widgets/query_url_sync.dart';

class AppointmentListScreen extends StatefulWidget {
  final Map<String, String> queryParameters;

  const AppointmentListScreen({super.key, this.queryParameters = const {}});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EntityListNotifier<Appointment>>().applyQuery(
      listQueryFromParams(widget.queryParameters, defaultSort: 'scheduledAt'),
    );
  }

  String _date(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<EntityListNotifier<Appointment>>();
    return QueryUrlSync(
      path: '/appointments',
      listenable: notifier,
      queryOf: () => notifier.query,
      child: ListScaffold<Appointment>(
        title: 'Записи к ветеринару',
        currentPath: '/appointments',
        controller: notifier,
        idOf: (appointment) => appointment.id,
        isDeleted: (appointment) => appointment.isDeleted,
        filters: appointmentFilterSpecs,
        onFiltersChanged: notifier.applyFilters,
        queryOf: () => notifier.query,
        createLabel: 'Новая запись',
        onCreate: (context) => context.push('/appointments/new'),
        onOpen: (context, appointment) =>
            context.push('/appointments/${appointment.id}'),
        onEdit: (context, appointment) =>
            context.push('/appointments/${appointment.id}/edit'),
        columns: [
          TableColumnSpec(
            label: 'Дата',
            sortField: 'scheduledAt',
            build: (appointment) => Text(_date(appointment.scheduledAt)),
          ),
          TableColumnSpec(
            label: 'Покупатель',
            build: (appointment) => Text(appointment.customerName),
          ),
          TableColumnSpec(
            label: 'Животное',
            build: (appointment) => Text(appointment.animalName),
          ),
          TableColumnSpec(
            label: 'Ветеринар',
            build: (appointment) => Text(appointment.vetName),
          ),
          TableColumnSpec(
            label: 'Статус',
            sortField: 'status',
            build: (appointment) => Text(_status(appointment.status)),
          ),
        ],
      ),
    );
  }

  String _status(String value) => switch (value) {
    'done' => 'Завершена',
    'cancelled' => 'Отменена',
    _ => 'Запланирована',
  };
}

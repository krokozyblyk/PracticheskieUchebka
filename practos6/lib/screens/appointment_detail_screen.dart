import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/detail_scaffold.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final int id;

  const AppointmentDetailScreen({super.key, required this.id});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  Appointment? _appointment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appointment = await context.read<AppointmentRepository>().findById(
      widget.id,
    );
    if (!mounted) return;
    setState(() {
      _appointment = appointment;
      _loading = false;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/appointments');
    }
  }

  String _date(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _status(String value) => switch (value) {
    'done' => 'Завершена',
    'cancelled' => 'Отменена',
    _ => 'Запланирована',
  };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Запись')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final appointment = _appointment;
    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Запись')),
        body: const Center(child: Text('Запись не найдена')),
      );
    }
    return DetailScaffold(
      title: 'Запись №${appointment.id}',
      currentPath: '/appointments',
      isDeleted: appointment.isDeleted,
      rows: [
        DetailRow('Дата и время', _date(appointment.scheduledAt)),
        DetailRow('Длительность', '${appointment.durationMinutes} мин'),
        DetailRow('Покупатель', appointment.customerName),
        DetailRow('Животное', appointment.animalName),
        DetailRow('Ветеринар', appointment.vetName),
        DetailRow('Статус', _status(appointment.status)),
        DetailRow(
          'Причина',
          appointment.notes.isEmpty ? '—' : appointment.notes,
        ),
      ],
      onEdit: () => context.push('/appointments/${appointment.id}/edit'),
      onDelete: () async {
        final repository = context.read<AppointmentRepository>();
        final notifier = context.read<EntityListNotifier<Appointment>>();
        await repository.softDelete(appointment.id);
        await notifier.load();
        if (!mounted) return;
        _close();
      },
      onRestore: () async {
        final repository = context.read<AppointmentRepository>();
        final notifier = context.read<EntityListNotifier<Appointment>>();
        await repository.restore(appointment.id);
        await notifier.load();
        if (!mounted) return;
        await _load();
      },
      onHardDelete: () async {
        final repository = context.read<AppointmentRepository>();
        final notifier = context.read<EntityListNotifier<Appointment>>();
        await repository.hardDelete(appointment.id);
        await notifier.load();
        if (!mounted) return;
        _close();
      },
    );
  }
}

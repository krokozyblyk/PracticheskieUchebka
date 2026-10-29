import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../logic/validators.dart';
import '../models/animal.dart';
import '../models/appointment.dart';
import '../models/customer.dart';
import '../models/animal_query.dart';
import '../models/list_query.dart';
import '../models/vet.dart';
import '../repositories/animal_repository.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/vet_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';
import '../widgets/entity_form.dart';

class AppointmentFormScreen extends StatefulWidget {
  final int? id;

  const AppointmentFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<EntityFormState>();
  Appointment? _appointment;
  List<Customer> _customers = const [];
  List<Animal> _animals = const [];
  List<Vet> _vets = const [];
  bool _loading = true;
  bool _notFound = false;
  Map<String, String> _serverErrors = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final customerRepository = context.read<CustomerRepository>();
    final animalRepository = context.read<AnimalRepository>();
    final vetRepository = context.read<VetRepository>();
    final appointmentRepository = context.read<AppointmentRepository>();
    final customers = await customerRepository.find(
      const ListQuery(size: 1000),
    );
    final animals = await animalRepository.find(const AnimalQuery(size: 1000));
    final vets = await vetRepository.find(const ListQuery(size: 1000));
    Appointment? appointment;
    if (widget.id != null) {
      appointment = await appointmentRepository.findById(widget.id!);
    }
    if (!mounted) return;
    setState(() {
      _customers = customers.items;
      _animals = animals.items;
      _vets = vets.items;
      _appointment = appointment;
      _notFound = widget.id != null && appointment == null;
      _loading = false;
    });
  }

  String _inputDate(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String value) {
    return DateTime.tryParse(value.trim().replaceFirst(' ', 'T'));
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    setState(() => _serverErrors = const {});
    if (!form.validate()) return;
    final date = _parseDate(form.textValue('scheduledAt'));
    if (date == null) return;
    final appointment = Appointment(
      id: _appointment?.id ?? 0,
      customerId: form.dropdownValue<int>('customerId') ?? 0,
      animalId: form.dropdownValue<int>('animalId') ?? 0,
      vetId: form.dropdownValue<int>('vetId') ?? 0,
      scheduledAt: date,
      durationMinutes: parseIntValue(form.textValue('durationMinutes')) ?? 30,
      status: form.dropdownValue<String>('status') ?? 'planned',
      notes: form.textValue('notes'),
    );
    final repository = context.read<AppointmentRepository>();
    final notifier = context.read<EntityListNotifier<Appointment>>();
    try {
      if (widget.isEditing) {
        await repository.update(appointment);
      } else {
        await repository.create(appointment);
      }
    } on ValidationException catch (error) {
      setState(() => _serverErrors = error.errors);
      form.revalidate();
      return;
    } on ApiException catch (error) {
      if (mounted) showApiError(context, error);
      return;
    }
    await notifier.load();
    if (!mounted) return;
    _close();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/appointments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing ? 'Редактирование записи' : 'Новая запись',
      currentPath: '/appointments',
      showNavigation: false,
      leading: IconButton(
        tooltip: 'Назад',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _formKey.currentState?.requestExit(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notFound) {
      return const Center(child: Text('Запись не найдена'));
    }
    final appointment = _appointment;
    return EntityForm(
      key: _formKey,
      fields: [
        DropdownFieldSpec<int>(
          key: 'customerId',
          label: 'Покупатель',
          initialValue: appointment?.customerId,
          items: [
            for (final customer in _customers)
              DropdownMenuItem(
                value: customer.id,
                child: Text(customer.fullName),
              ),
          ],
          validator: (value) => value == null ? 'Выберите покупателя' : null,
        ),
        DropdownFieldSpec<int>(
          key: 'animalId',
          label: 'Животное',
          initialValue: appointment?.animalId,
          items: [
            for (final animal in _animals)
              DropdownMenuItem(value: animal.id, child: Text(animal.name)),
          ],
          validator: (value) => value == null ? 'Выберите животное' : null,
        ),
        DropdownFieldSpec<int>(
          key: 'vetId',
          label: 'Ветеринар',
          initialValue: appointment?.vetId,
          items: [
            for (final vet in _vets)
              DropdownMenuItem(value: vet.id, child: Text(vet.fullName)),
          ],
          validator: (value) => value == null ? 'Выберите ветеринара' : null,
        ),
        TextFieldSpec(
          key: 'scheduledAt',
          label: 'Дата и время',
          initialValue: _inputDate(appointment?.scheduledAt),
          hint: 'Например, 2026-11-05 14:30',
          validator: (value) {
            if (requiredValidator(value) != null) return 'Укажите дату';
            if (_parseDate(value ?? '') == null) {
              return 'Формат: ГГГГ-ММ-ДД ЧЧ:ММ';
            }
            return null;
          },
        ),
        TextFieldSpec(
          key: 'durationMinutes',
          label: 'Длительность, минут',
          initialValue: '${appointment?.durationMinutes ?? 30}',
          keyboardType: TextInputType.number,
          validator: intRangeValidator(15, 240),
        ),
        DropdownFieldSpec<String>(
          key: 'status',
          label: 'Статус',
          initialValue: appointment?.status ?? 'planned',
          items: const [
            DropdownMenuItem(value: 'planned', child: Text('Запланирована')),
            DropdownMenuItem(value: 'done', child: Text('Завершена')),
            DropdownMenuItem(value: 'cancelled', child: Text('Отменена')),
          ],
        ),
        TextFieldSpec(
          key: 'notes',
          label: 'Причина визита',
          initialValue: appointment?.notes ?? '',
          maxLines: 3,
          maxLength: 500,
        ),
      ],
      submitLabel: widget.isEditing ? 'Сохранить' : 'Записать',
      onSubmit: _save,
      onCancel: _close,
      serverErrors: _serverErrors,
    );
  }
}

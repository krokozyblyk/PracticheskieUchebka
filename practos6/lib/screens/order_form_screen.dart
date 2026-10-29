import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../logic/validators.dart';
import '../models/animal.dart';
import '../models/customer.dart';
import '../models/animal_query.dart';
import '../models/list_query.dart';
import '../models/order.dart';
import '../repositories/animal_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/order_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';
import '../widgets/entity_form.dart';

class OrderFormScreen extends StatefulWidget {
  final int? id;

  const OrderFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<EntityFormState>();
  Order? _order;
  List<Customer> _customers = const [];
  List<Animal> _animals = const [];
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
    final orderRepository = context.read<OrderRepository>();
    final customers = await customerRepository.find(
      const ListQuery(size: 1000),
    );
    final animals = await animalRepository.find(const AnimalQuery(size: 1000));
    Order? order;
    if (widget.id != null) {
      order = await orderRepository.findById(widget.id!);
    }
    if (!mounted) return;
    setState(() {
      _customers = customers.items;
      _animals = animals.items;
      _order = order;
      _notFound = widget.id != null && order == null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    setState(() => _serverErrors = const {});
    if (!form.validate()) return;
    final order = Order(
      id: _order?.id ?? 0,
      customerId: form.dropdownValue<int>('customerId') ?? 0,
      animalId: form.dropdownValue<int>('animalId') ?? 0,
      quantity: parseIntValue(form.textValue('quantity')) ?? 0,
      status: form.dropdownValue<String>('status') ?? 'new',
      notes: form.textValue('notes'),
    );
    final repository = context.read<OrderRepository>();
    final notifier = context.read<EntityListNotifier<Order>>();
    try {
      if (widget.isEditing) {
        await repository.update(order);
      } else {
        await repository.create(order);
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
      context.go('/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing ? 'Редактирование заказа' : 'Новый заказ',
      currentPath: '/orders',
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
      return const Center(child: Text('Заказ не найден'));
    }
    final order = _order;
    return EntityForm(
      key: _formKey,
      fields: [
        DropdownFieldSpec<int>(
          key: 'customerId',
          label: 'Покупатель',
          initialValue: order?.customerId,
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
          initialValue: order?.animalId,
          items: [
            for (final animal in _animals)
              DropdownMenuItem(
                value: animal.id,
                child: Text(
                  '${animal.name} · ${animal.quantity} шт. · '
                  '${animal.price.toStringAsFixed(0)} ₽',
                ),
              ),
          ],
          validator: (value) => value == null ? 'Выберите животное' : null,
        ),
        TextFieldSpec(
          key: 'quantity',
          label: 'Количество',
          initialValue: '${order?.quantity ?? 1}',
          keyboardType: TextInputType.number,
          validator: combineValidators([
            (value) => requiredValidator(value),
            intRangeValidator(1, 1000),
          ]),
        ),
        DropdownFieldSpec<String>(
          key: 'status',
          label: 'Статус',
          initialValue: order?.status ?? 'new',
          items: const [
            DropdownMenuItem(value: 'new', child: Text('Новый')),
            DropdownMenuItem(value: 'paid', child: Text('Оплачен')),
            DropdownMenuItem(value: 'cancelled', child: Text('Отменён')),
          ],
        ),
        TextFieldSpec(
          key: 'notes',
          label: 'Комментарий',
          initialValue: order?.notes ?? '',
          maxLines: 3,
          maxLength: 500,
        ),
      ],
      submitLabel: widget.isEditing ? 'Сохранить' : 'Оформить',
      onSubmit: _save,
      onCancel: _close,
      serverErrors: _serverErrors,
    );
  }
}

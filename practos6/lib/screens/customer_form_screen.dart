import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../logic/validators.dart';
import '../models/customer.dart';
import '../models/loyalty_card.dart';
import '../repositories/customer_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';
import '../widgets/entity_form.dart';

class CustomerFormScreen extends StatefulWidget {
  final int? id;

  const CustomerFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<EntityFormState>();
  Customer? _customer;
  bool _loading = true;
  bool _notFound = false;
  bool _hasCard = false;
  Map<String, String> _serverErrors = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    Customer? customer;
    if (widget.id != null) {
      customer = await context.read<CustomerRepository>().findById(widget.id!);
    }
    if (!mounted) return;
    setState(() {
      _customer = customer;
      _hasCard = customer?.loyaltyCard != null;
      _notFound = widget.id != null && customer == null;
      _loading = false;
    });
  }

  String? _validateEmail(String? value) {
    return combineValidators([
      (value) => requiredValidator(value),
      emailValidator,
    ])(value);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    setState(() => _serverErrors = const {});
    if (!form.validate()) return;

    final repository = context.read<CustomerRepository>();
    final listNotifier = context.read<EntityListNotifier<Customer>>();
    final email = form.textValue('email');

    final hasCard = form.switchValue('hasCard');
    LoyaltyCard? card;
    if (hasCard) {
      final issuedAt =
          DateTime.tryParse(form.textValue('issuedAt')) ?? DateTime.now();
      card = LoyaltyCard(
        cardNumber: form.textValue('cardNumber'),
        issuedAt: issuedAt,
        discountPercent: parseIntValue(form.textValue('discountPercent')) ?? 0,
        active: form.switchValue('cardActive'),
      );
    }

    final customer = Customer(
      id: _customer?.id ?? 0,
      fullName: form.textValue('fullName'),
      email: email,
      phone: form.textValue('phone'),
      address: form.textValue('address'),
      loyaltyCard: card,
    );

    try {
      if (widget.isEditing) {
        await repository.update(customer);
      } else {
        await repository.create(customer);
      }
    } on ValidationException catch (error) {
      setState(() => _serverErrors = error.errors);
      form.revalidate();
      return;
    } on ApiException catch (error) {
      if (mounted) showApiError(context, error);
      return;
    }
    await listNotifier.load();
    _close();
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
    return AppScaffold(
      title: widget.isEditing
          ? '?????????????? ??????????'
          : '????? ??????????',
      currentPath: '/customers',
      showNavigation: false,
      leading: IconButton(
        tooltip: '?????',
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
      return const Center(child: Text('Покупатель не найден'));
    }
    final customer = _customer;
    final card = customer?.loyaltyCard;

    return EntityForm(
      key: _formKey,
      fields: [
        TextFieldSpec(
          key: 'fullName',
          label: 'ФИО',
          initialValue: customer?.fullName ?? '',
          validator: combineValidators([
            (value) => requiredValidator(value),
            lengthValidator(3, 60),
          ]),
        ),
        TextFieldSpec(
          key: 'email',
          label: 'Почта',
          initialValue: customer?.email ?? '',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        TextFieldSpec(
          key: 'phone',
          label: 'Телефон',
          initialValue: customer?.phone ?? '',
          keyboardType: TextInputType.phone,
          validator: combineValidators([
            (value) => requiredValidator(value),
            phoneValidator,
          ]),
        ),
        TextFieldSpec(
          key: 'address',
          label: 'Адрес',
          initialValue: customer?.address ?? '',
          maxLength: 100,
          validator: maxLengthValidator(100),
        ),
        SectionSpec(
          key: 'loyalty',
          title: 'Карта лояльности',
          children: [
            SwitchFieldSpec(
              key: 'hasCard',
              label: 'Есть карта лояльности',
              initialValue: _hasCard,
              onChanged: (value) => setState(() => _hasCard = value),
            ),
            TextFieldSpec(
              key: 'cardNumber',
              label: 'Номер карты',
              initialValue: card?.cardNumber ?? '',
              hint: 'например, LC-1003',
              validator: (value) => _hasCard
                  ? combineValidators([
                      (value) => requiredValidator(value),
                      cardNumberValidator,
                    ])(value)
                  : null,
            ),
            TextFieldSpec(
              key: 'issuedAt',
              label: 'Дата выдачи',
              initialValue: card == null ? '' : _formatDate(card.issuedAt),
              hint: 'ГГГГ-ММ-ДД',
              validator: (value) {
                if (!_hasCard) return null;
                final required = requiredValidator(value);
                if (required != null) return required;
                if (DateTime.tryParse(value!.trim()) == null) {
                  return 'Формат даты: ГГГГ-ММ-ДД';
                }
                return null;
              },
            ),
            TextFieldSpec(
              key: 'discountPercent',
              label: 'Скидка, %',
              initialValue: card?.discountPercent.toString() ?? '',
              keyboardType: TextInputType.number,
              validator: (value) => _hasCard
                  ? combineValidators([
                      (value) => requiredValidator(value),
                      discountValidator,
                    ])(value)
                  : null,
            ),
            SwitchFieldSpec(
              key: 'cardActive',
              label: 'Карта активна',
              initialValue: card?.active ?? true,
            ),
          ],
        ),
      ],
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      onSubmit: _save,
      onCancel: _close,
      serverErrors: _serverErrors,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/validators.dart';
import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/entity_form.dart';

class SupplierFormScreen extends StatefulWidget {
  final int? id;

  const SupplierFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<EntityFormState>();
  Supplier? _supplier;
  bool _loading = true;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    Supplier? supplier;
    if (widget.id != null) {
      supplier = await context.read<SupplierRepository>().findById(widget.id!);
    }
    if (!mounted) return;
    setState(() {
      _supplier = supplier;
      _notFound = widget.id != null && supplier == null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    final supplier = Supplier(
      id: _supplier?.id ?? 0,
      name: form.textValue('name'),
      contactPerson: form.textValue('contactPerson'),
      phone: form.textValue('phone'),
      email: form.textValue('email'),
    );
    final repository = context.read<SupplierRepository>();
    final listNotifier = context.read<EntityListNotifier<Supplier>>();
    if (widget.isEditing) {
      await repository.update(supplier);
    } else {
      await repository.create(supplier);
    }
    await listNotifier.load();
    _close();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/suppliers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Назад',
          onPressed: () => _formKey.currentState?.requestExit(),
        ),
        title: Text(
          widget.isEditing ? 'Редактирование поставщика' : 'Новый поставщик',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notFound) {
      return const Center(child: Text('Поставщик не найден'));
    }
    final supplier = _supplier;
    return EntityForm(
      key: _formKey,
      fields: [
        TextFieldSpec(
          key: 'name',
          label: 'Название',
          initialValue: supplier?.name ?? '',
          validator: combineValidators([
            (value) => requiredValidator(value),
            lengthValidator(2, 40),
          ]),
        ),
        TextFieldSpec(
          key: 'contactPerson',
          label: 'Контактное лицо',
          initialValue: supplier?.contactPerson ?? '',
          validator: combineValidators([
            (value) => requiredValidator(value),
            lengthValidator(2, 60),
          ]),
        ),
        TextFieldSpec(
          key: 'phone',
          label: 'Телефон',
          initialValue: supplier?.phone ?? '',
          hint: '+7 900 000-00-00',
          keyboardType: TextInputType.phone,
          validator: combineValidators([
            (value) => requiredValidator(value),
            phoneValidator,
          ]),
        ),
        TextFieldSpec(
          key: 'email',
          label: 'Почта',
          initialValue: supplier?.email ?? '',
          keyboardType: TextInputType.emailAddress,
          validator: combineValidators([
            (value) => requiredValidator(value),
            emailValidator,
          ]),
        ),
      ],
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      onSubmit: _save,
      onCancel: _close,
    );
  }
}

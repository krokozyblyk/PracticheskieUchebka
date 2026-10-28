import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../logic/validators.dart';
import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';
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
  Map<String, String> _serverErrors = const {};

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
    setState(() => _serverErrors = const {});
    final supplier = Supplier(
      id: _supplier?.id ?? 0,
      name: form.textValue('name'),
      contactPerson: form.textValue('contactPerson'),
      phone: form.textValue('phone'),
      email: form.textValue('email'),
    );
    final repository = context.read<SupplierRepository>();
    final listNotifier = context.read<EntityListNotifier<Supplier>>();
    try {
      if (widget.isEditing) {
        await repository.update(supplier);
      } else {
        await repository.create(supplier);
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
      context.go('/suppliers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing ? '?????????????? ??????????' : '????? ?????????',
      currentPath: '/suppliers',
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
      serverErrors: _serverErrors,
    );
  }
}

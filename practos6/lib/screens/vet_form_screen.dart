import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../logic/validators.dart';
import '../models/category.dart' as model;
import '../models/list_query.dart';
import '../models/vet.dart';
import '../repositories/category_repository.dart';
import '../repositories/vet_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';
import '../widgets/entity_form.dart';

class VetFormScreen extends StatefulWidget {
  final int? id;

  const VetFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<VetFormScreen> createState() => _VetFormScreenState();
}

class _VetFormScreenState extends State<VetFormScreen> {
  final _formKey = GlobalKey<EntityFormState>();
  Vet? _vet;
  List<model.Category> _categories = [];
  bool _loading = true;
  bool _notFound = false;
  Map<String, String> _serverErrors = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categoryRepository = context.read<CategoryRepository>();
    final vetRepository = context.read<VetRepository>();
    final categories = await categoryRepository.find(
      const ListQuery(size: 1000),
    );
    Vet? vet;
    if (widget.id != null) {
      vet = await vetRepository.findById(widget.id!);
    }
    if (!mounted) return;
    setState(() {
      _categories = categories.items;
      _vet = vet;
      _notFound = widget.id != null && vet == null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    setState(() => _serverErrors = const {});
    final vet = Vet(
      id: _vet?.id ?? 0,
      fullName: form.textValue('fullName'),
      specializationCategoryId:
          form.dropdownValue<int>('specializationCategoryId') ?? 0,
      phone: form.textValue('phone'),
      email: form.textValue('email'),
    );
    final repository = context.read<VetRepository>();
    final listNotifier = context.read<EntityListNotifier<Vet>>();
    try {
      if (widget.isEditing) {
        await repository.update(vet);
      } else {
        await repository.create(vet);
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
      context.go('/vets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing ? '?????????????? ??????????' : '????? ?????????',
      currentPath: '/vets',
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
      return const Center(child: Text('Ветеринар не найден'));
    }
    final vet = _vet;
    final specializationIds = _categories.map((c) => c.id).toSet();
    final initialSpecialization =
        specializationIds.contains(vet?.specializationCategoryId)
        ? vet?.specializationCategoryId
        : null;

    return EntityForm(
      key: _formKey,
      fields: [
        TextFieldSpec(
          key: 'fullName',
          label: 'ФИО',
          initialValue: vet?.fullName ?? '',
          validator: combineValidators([
            (value) => requiredValidator(value),
            lengthValidator(3, 60),
          ]),
        ),
        DropdownFieldSpec<int>(
          key: 'specializationCategoryId',
          label: 'Специализация',
          initialValue: initialSpecialization,
          items: _categories
              .map(
                (category) => DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
                ),
              )
              .toList(),
          validator: (value) => value == null ? 'Выберите специализацию' : null,
        ),
        TextFieldSpec(
          key: 'phone',
          label: 'Телефон',
          initialValue: vet?.phone ?? '',
          keyboardType: TextInputType.phone,
          validator: combineValidators([
            (value) => requiredValidator(value),
            phoneValidator,
          ]),
        ),
        TextFieldSpec(
          key: 'email',
          label: 'Почта',
          initialValue: vet?.email ?? '',
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

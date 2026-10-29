import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../logic/validators.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import '../state/entity_list_notifier.dart';
import '../widgets/api_error.dart';
import '../widgets/app_navigation.dart';
import '../widgets/entity_form.dart';

class CategoryFormScreen extends StatefulWidget {
  final int? id;

  const CategoryFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<EntityFormState>();
  Category? _category;
  bool _loading = true;
  bool _notFound = false;
  Map<String, String> _serverErrors = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    Category? category;
    if (widget.id != null) {
      category = await context.read<CategoryRepository>().findById(widget.id!);
    }
    if (!mounted) return;
    setState(() {
      _category = category;
      _notFound = widget.id != null && category == null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    setState(() => _serverErrors = const {});
    if (!form.validate()) return;

    final category = Category(
      id: _category?.id ?? 0,
      name: form.textValue('name'),
      section: form.textValue('section'),
    );
    final repository = context.read<CategoryRepository>();
    final listNotifier = context.read<EntityListNotifier<Category>>();
    try {
      if (widget.isEditing) {
        await repository.update(category);
      } else {
        await repository.create(category);
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
      context.go('/categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing ? 'Редактирование категории' : 'Новая категория',
      currentPath: '/categories',
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
      return const Center(child: Text('Категория не найдена'));
    }
    final category = _category;
    return EntityForm(
      key: _formKey,
      fields: [
        TextFieldSpec(
          key: 'name',
          label: 'Название',
          initialValue: category?.name ?? '',
          validator: combineValidators([
            (value) => requiredValidator(value),
            lengthValidator(2, 30),
          ]),
        ),
        TextFieldSpec(
          key: 'section',
          label: 'Раздел',
          initialValue: category?.section ?? '',
          validator: combineValidators([
            (value) => requiredValidator(value),
            lengthValidator(2, 30),
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

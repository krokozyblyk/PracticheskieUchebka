import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../logic/validators.dart';
import '../models/animal.dart';
import '../models/category.dart' as model;
import '../models/list_query.dart';
import '../models/supplier.dart';
import '../models/vet.dart';
import '../repositories/animal_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/supplier_repository.dart';
import '../repositories/vet_repository.dart';
import '../state/animal_list_notifier.dart';
import '../widgets/chips_field.dart';
import '../widgets/entity_form.dart';

class AnimalFormScreen extends StatefulWidget {
  final int? id;

  const AnimalFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<EntityFormState>();

  Animal? _animal;
  List<model.Category> _categories = [];
  List<Supplier> _suppliers = [];
  List<Vet> _vets = [];
  List<int> _selectedCategories = [];
  List<int> _selectedVets = [];
  bool _loading = true;
  bool _notFound = false;
  String? _skuError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final animalRepository = context.read<AnimalRepository>();
    final categoryRepository = context.read<CategoryRepository>();
    final supplierRepository = context.read<SupplierRepository>();
    final vetRepository = context.read<VetRepository>();
    final categoriesResult =
        await categoryRepository.find(const ListQuery(size: 1000));
    final suppliersResult =
        await supplierRepository.find(const ListQuery(size: 1000));
    final vetsResult = await vetRepository.find(const ListQuery(size: 1000));

    Animal? animal;
    if (widget.id != null) {
      animal = await animalRepository.findById(widget.id!);
    }

    if (!mounted) return;
    setState(() {
      _categories = categoriesResult.items;
      _suppliers = suppliersResult.items;
      _vets = vetsResult.items;
      _animal = animal;
      _notFound = widget.id != null && animal == null;
      _selectedCategories = [...(animal?.categoryIds ?? const <int>[])];
      _selectedVets = [...(animal?.vetIds ?? const <int>[])];
      _loading = false;
    });
  }

  String? _validateSku(String? value) {
    final base = combineValidators([
      (value) => requiredValidator(value),
      skuValidator,
    ])(value);
    if (base != null) return base;
    return _skuError;
  }

  void _onCategoriesChanged(List<int> ids) {
    setState(() {
      _selectedCategories = ids;
      final allowed = _vets
          .where((vet) =>
              ids.isEmpty || ids.contains(vet.specializationCategoryId))
          .map((vet) => vet.id)
          .toSet();
      final filtered = _selectedVets.where(allowed.contains).toList();
      if (filtered.length != _selectedVets.length) {
        _selectedVets = filtered;
        _formKey.currentState?.setValue('vetIds', filtered);
      }
    });
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    setState(() => _skuError = null);
    if (!form.validate()) return;

    final repository = context.read<AnimalRepository>();
    final listNotifier = context.read<AnimalListNotifier>();
    final sku = form.textValue('sku');
    final duplicate = await repository.existsSku(sku, exceptId: widget.id);
    if (duplicate) {
      setState(() => _skuError = 'Артикул уже используется');
      form.revalidate();
      return;
    }

    final animal = Animal(
      id: _animal?.id ?? 0,
      name: form.textValue('name'),
      species: form.textValue('species'),
      sku: sku.toUpperCase(),
      age: parseIntValue(form.textValue('age')) ?? 0,
      price: parseDoubleValue(form.textValue('price')) ?? 0,
      supplierId: form.dropdownValue<int>('supplierId') ?? 0,
      categoryIds: form.chipsValue('categoryIds'),
      vetIds: form.chipsValue('vetIds'),
      quantity: parseIntValue(form.textValue('quantity')) ?? 0,
      description: form.textValue('description'),
    );

    if (widget.isEditing) {
      await repository.update(animal);
    } else {
      await repository.create(animal);
    }

    await listNotifier.load();
    _close();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/animals');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? 'Редактирование животного'
        : 'Новое животное';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Назад',
          onPressed: () => _formKey.currentState?.requestExit(),
        ),
        title: Text(title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notFound) {
      return const Center(child: Text('Животное не найдено'));
    }

    final animal = _animal;
    final supplierIds = _suppliers.map((s) => s.id).toSet();
    final initialSupplier = supplierIds.contains(animal?.supplierId)
        ? animal?.supplierId
        : null;

    final vetOptions = _vets
        .where((vet) =>
            _selectedCategories.isEmpty ||
            _selectedCategories.contains(vet.specializationCategoryId))
        .map((vet) => ChipOption(
              id: vet.id,
              label: vet.fullName,
            ))
        .toList();

    final fields = <FieldSpec>[
      TextFieldSpec(
        key: 'name',
        label: 'Кличка',
        initialValue: animal?.name ?? '',
        validator: combineValidators([
          (value) => requiredValidator(value),
          lengthValidator(2, 40),
        ]),
      ),
      TextFieldSpec(
        key: 'sku',
        label: 'Артикул',
        initialValue: animal?.sku ?? '',
        hint: 'например, AN-021',
        validator: _validateSku,
      ),
      TextFieldSpec(
        key: 'species',
        label: 'Вид',
        initialValue: animal?.species ?? '',
        validator: combineValidators([
          (value) => requiredValidator(value),
          lengthValidator(2, 30),
        ]),
      ),
      TextFieldSpec(
        key: 'age',
        label: 'Возраст, лет',
        initialValue: animal?.age.toString() ?? '',
        keyboardType: TextInputType.number,
        validator: combineValidators([
          (value) => requiredValidator(value),
          intRangeValidator(0, 50),
        ]),
      ),
      TextFieldSpec(
        key: 'price',
        label: 'Цена, ₽',
        initialValue: animal?.price.toString() ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: combineValidators([
          (value) => requiredValidator(value),
          priceValidator,
        ]),
      ),
      TextFieldSpec(
        key: 'quantity',
        label: 'Количество на складе',
        initialValue: animal?.quantity.toString() ?? '',
        keyboardType: TextInputType.number,
        validator: combineValidators([
          (value) => requiredValidator(value),
          quantityValidator,
        ]),
      ),
      TextFieldSpec(
        key: 'description',
        label: 'Описание',
        initialValue: animal?.description ?? '',
        maxLines: 3,
        maxLength: 300,
      ),
      DropdownFieldSpec<int>(
        key: 'supplierId',
        label: 'Поставщик',
        initialValue: initialSupplier,
        items: _suppliers
            .map((supplier) => DropdownMenuItem<int>(
                  value: supplier.id,
                  child: Text(supplier.name),
                ))
            .toList(),
        validator: (value) =>
            value == null ? 'Выберите поставщика' : null,
      ),
      ChipsFieldSpec(
        key: 'categoryIds',
        label: 'Категории',
        initialValue: animal?.categoryIds ?? const [],
        options: _categories
            .map((category) => ChipOption(
                  id: category.id,
                  label: category.name,
                ))
            .toList(),
        validator: (value) =>
            value.isEmpty ? 'Выберите хотя бы одну категорию' : null,
        onChanged: _onCategoriesChanged,
      ),
      ChipsFieldSpec(
        key: 'vetIds',
        label: 'Ветеринары',
        initialValue: animal?.vetIds ?? const [],
        options: vetOptions,
        onChanged: (value) => _selectedVets = value,
      ),
    ];

    return EntityForm(
      key: _formKey,
      fields: fields,
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      onSubmit: _save,
      onCancel: _close,
    );
  }
}

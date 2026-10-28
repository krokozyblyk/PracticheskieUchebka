import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final int? categoryId;
  final int? supplierId;
  final int? vetId;
  final String? priceFrom;
  final String? priceTo;
  final bool includeDeleted;
  final List<DropdownMenuItem<int>> categoryItems;
  final List<DropdownMenuItem<int>> supplierItems;
  final List<DropdownMenuItem<int>> vetItems;
  final ValueChanged<int?> onCategory;
  final ValueChanged<int?> onSupplier;
  final ValueChanged<int?> onVet;
  final ValueChanged<String?> onPriceFrom;
  final ValueChanged<String?> onPriceTo;
  final ValueChanged<bool> onIncludeDeleted;
  final VoidCallback onReset;

  const FilterPanel({
    super.key,
    required this.categoryId,
    required this.supplierId,
    required this.vetId,
    required this.priceFrom,
    required this.priceTo,
    required this.includeDeleted,
    required this.categoryItems,
    required this.supplierItems,
    required this.vetItems,
    required this.onCategory,
    required this.onSupplier,
    required this.onVet,
    required this.onPriceFrom,
    required this.onPriceTo,
    required this.onIncludeDeleted,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<int?>(
            initialValue: categoryId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Категория',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Все')),
              ...categoryItems,
            ],
            onChanged: onCategory,
          ),
        ),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<int?>(
            initialValue: supplierId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Поставщик',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Все')),
              ...supplierItems,
            ],
            onChanged: onSupplier,
          ),
        ),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<int?>(
            initialValue: vetId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Ветеринар',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Все')),
              ...vetItems,
            ],
            onChanged: onVet,
          ),
        ),
        SizedBox(
          width: 130,
          child: TextField(
            controller: TextEditingController(text: priceFrom),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Цена от',
              border: OutlineInputBorder(),
            ),
            onSubmitted: onPriceFrom,
          ),
        ),
        SizedBox(
          width: 130,
          child: TextField(
            controller: TextEditingController(text: priceTo),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Цена до',
              border: OutlineInputBorder(),
            ),
            onSubmitted: onPriceTo,
          ),
        ),
        FilterChip(
          label: const Text('Показывать удалённые'),
          selected: includeDeleted,
          onSelected: onIncludeDeleted,
        ),
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.clear_all),
          label: const Text('Сбросить'),
        ),
      ],
    );
  }
}

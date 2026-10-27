import 'package:flutter/material.dart';

class ChipOption {
  final int id;
  final String label;

  const ChipOption({required this.id, required this.label});
}

class ChipsField extends StatelessWidget {
  final String label;
  final List<ChipOption> options;
  final List<int> value;
  final String? Function(List<int>)? validator;
  final ValueChanged<List<int>>? onChanged;
  final bool enabled;

  const ChipsField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<List<int>>(
      initialValue: value,
      validator: (_) => validator?.call(value),
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          isEmpty: false,
          child: options.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Нет доступных значений'),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options
                      .map(
                        (option) => FilterChip(
                          label: Text(option.label),
                          selected: value.contains(option.id),
                          onSelected: enabled
                              ? (_) {
                                  final next = [...value];
                                  if (next.contains(option.id)) {
                                    next.remove(option.id);
                                  } else {
                                    next.add(option.id);
                                  }
                                  field.didChange(next);
                                  onChanged?.call(next);
                                }
                              : null,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

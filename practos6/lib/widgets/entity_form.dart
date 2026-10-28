import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'chips_field.dart';

sealed class FieldSpec {
  final String key;

  const FieldSpec({required this.key});
}

class TextFieldSpec extends FieldSpec {
  final String label;
  final String initialValue;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const TextFieldSpec({
    required super.key,
    required this.label,
    this.initialValue = '',
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
  });
}

class DropdownFieldSpec<T> extends FieldSpec {
  final String label;
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final String? Function(Object?)? validator;
  final ValueChanged<Object?>? onChanged;
  final bool enabled;

  const DropdownFieldSpec({
    required super.key,
    required this.label,
    required this.initialValue,
    required this.items,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });
}

class ChipsFieldSpec extends FieldSpec {
  final String label;
  final List<int> initialValue;
  final List<ChipOption> options;
  final String? Function(List<int>)? validator;
  final ValueChanged<List<int>>? onChanged;

  const ChipsFieldSpec({
    required super.key,
    required this.label,
    required this.initialValue,
    required this.options,
    this.validator,
    this.onChanged,
  });
}

class SwitchFieldSpec extends FieldSpec {
  final String label;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const SwitchFieldSpec({
    required super.key,
    required this.label,
    this.initialValue = false,
    this.onChanged,
  });
}

class SectionSpec extends FieldSpec {
  final String title;
  final List<FieldSpec> children;

  const SectionSpec({
    required super.key,
    required this.title,
    required this.children,
  });
}

class EntityForm extends StatefulWidget {
  final List<FieldSpec> fields;
  final String submitLabel;
  final Future<void> Function() onSubmit;
  final VoidCallback onCancel;
  final Map<String, String> serverErrors;

  const EntityForm({
    super.key,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    required this.onCancel,
    this.serverErrors = const {},
  });

  @override
  State<EntityForm> createState() => EntityFormState();
}

class EntityFormState extends State<EntityForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, Object?> _values = {};
  bool _submitting = false;
  bool _confirmedExit = false;

  @override
  void initState() {
    super.initState();
    _initFields(widget.fields);
  }

  @override
  void didUpdateWidget(covariant EntityForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initFields(widget.fields);
    if (!mapEquals(oldWidget.serverErrors, widget.serverErrors) &&
        widget.serverErrors.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formKey.currentState?.validate();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initFields(List<FieldSpec> fields) {
    for (final spec in fields) {
      switch (spec) {
        case TextFieldSpec():
          _controllers.putIfAbsent(
            spec.key,
            () => TextEditingController(text: spec.initialValue),
          );
        case DropdownFieldSpec():
          _values.putIfAbsent(spec.key, () => spec.initialValue);
        case ChipsFieldSpec():
          _values.putIfAbsent(spec.key, () => [...spec.initialValue]);
        case SwitchFieldSpec():
          _values.putIfAbsent(spec.key, () => spec.initialValue);
        case SectionSpec():
          _initFields(spec.children);
      }
    }
  }

  String textValue(String key) => _controllers[key]?.text.trim() ?? '';

  T? dropdownValue<T>(String key) => _values[key] as T?;

  List<int> chipsValue(String key) =>
      List<int>.from((_values[key] as List?) ?? const []);

  bool switchValue(String key) => (_values[key] as bool?) ?? false;

  void setValue(String key, Object? value) {
    setState(() {
      final controller = _controllers[key];
      if (controller != null) {
        controller.text = '${value ?? ''}';
      } else if (value is List) {
        _values[key] = List<int>.from(value);
      } else {
        _values[key] = value;
      }
    });
  }

  bool validate() => _formKey.currentState?.validate() ?? false;

  void revalidate() => _formKey.currentState?.validate();

  Future<void> requestExit() => _requestExit();

  bool get isDirty => _fieldsDirty(widget.fields);

  bool _fieldsDirty(List<FieldSpec> fields) {
    for (final spec in fields) {
      switch (spec) {
        case TextFieldSpec():
          if (textValue(spec.key) != spec.initialValue.trim()) return true;
        case DropdownFieldSpec():
          if (_values[spec.key] != spec.initialValue) return true;
        case ChipsFieldSpec():
          if (!listEquals(chipsValue(spec.key), spec.initialValue)) return true;
        case SwitchFieldSpec():
          if (switchValue(spec.key) != spec.initialValue) return true;
        case SectionSpec():
          if (_fieldsDirty(spec.children)) return true;
      }
    }
    return false;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _requestExit() async {
    if (!isDirty) {
      widget.onCancel();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Несохранённые изменения'),
        content: const Text(
          'В форме есть несохранённые данные. Выйти без сохранения?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Остаться'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() => _confirmedExit = true);
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _confirmedExit || !isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _requestExit();
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...widget.fields.map(_buildField),
            const SizedBox(height: 24),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(widget.submitLabel),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _submitting ? null : _requestExit,
                  child: const Text('Отмена'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(FieldSpec spec) {
    final child = switch (spec) {
      TextFieldSpec() => TextFormField(
        controller: _controllers[spec.key],
        decoration: InputDecoration(
          labelText: spec.label,
          hintText: spec.hint,
          border: const OutlineInputBorder(),
          counterText: spec.maxLength == null ? null : '',
        ),
        keyboardType: spec.keyboardType,
        maxLines: spec.maxLines,
        maxLength: spec.maxLength,
        validator: (value) =>
            widget.serverErrors[spec.key] ?? spec.validator?.call(value),
        onChanged: spec.onChanged,
      ),
      DropdownFieldSpec() => DropdownButtonFormField<Object?>(
        initialValue: _values[spec.key],
        isExpanded: true,
        decoration: InputDecoration(
          labelText: spec.label,
          border: const OutlineInputBorder(),
        ),
        items: spec.items.cast<DropdownMenuItem<Object?>>(),
        validator: (value) =>
            widget.serverErrors[spec.key] ?? spec.validator?.call(value),
        onChanged: spec.enabled
            ? (value) {
                setState(() => _values[spec.key] = value);
                spec.onChanged?.call(value);
              }
            : null,
      ),
      ChipsFieldSpec() => ChipsField(
        label: spec.label,
        options: spec.options,
        value: chipsValue(spec.key),
        validator: (value) =>
            widget.serverErrors[spec.key] ?? spec.validator?.call(value),
        onChanged: (next) {
          setState(() => _values[spec.key] = next);
          spec.onChanged?.call(next);
        },
      ),
      SwitchFieldSpec() => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(spec.label),
        value: switchValue(spec.key),
        onChanged: (value) {
          setState(() => _values[spec.key] = value);
          spec.onChanged?.call(value);
        },
      ),
      SectionSpec() => Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(spec.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...spec.children.map(_buildField),
            ],
          ),
        ),
      ),
    };
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: child,
        ),
      ),
    );
  }
}

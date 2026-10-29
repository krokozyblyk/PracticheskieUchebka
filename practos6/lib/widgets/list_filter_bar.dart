import 'dart:async';

import 'package:flutter/material.dart';

class ListFilterOption {
  final String value;
  final String label;

  const ListFilterOption(this.value, this.label);
}

class ListFilterSpec {
  final String key;
  final String label;
  final List<ListFilterOption> options;
  final bool text;

  const ListFilterSpec({
    required this.key,
    required this.label,
    this.options = const [],
    this.text = false,
  });
}

class ListFilterBar extends StatefulWidget {
  final List<ListFilterSpec> specs;
  final Map<String, String> initialValues;
  final ValueChanged<Map<String, String>> onChanged;

  const ListFilterBar({
    super.key,
    required this.specs,
    this.initialValues = const {},
    required this.onChanged,
  });

  @override
  State<ListFilterBar> createState() => _ListFilterBarState();
}

class _ListFilterBarState extends State<ListFilterBar> {
  late final Map<String, String> _values = {
    for (final spec in widget.specs)
      spec.key: widget.initialValues[spec.key] ?? '',
  };
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, Timer> _timers = {};

  @override
  void initState() {
    super.initState();
    for (final spec in widget.specs) {
      if (spec.text) {
        _controllers[spec.key] = TextEditingController(
          text: _values[spec.key] ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _emit(String key, String value, {bool debounce = false}) {
    _values[key] = value;
    _timers[key]?.cancel();
    if (!debounce) {
      widget.onChanged(Map.from(_values));
      return;
    }
    _timers[key] = Timer(const Duration(milliseconds: 400), () {
      if (mounted) widget.onChanged(Map.from(_values));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final spec in widget.specs)
          SizedBox(
            width: spec.text ? 190 : 210,
            child: spec.text
                ? TextField(
                    controller: _controllers[spec.key],
                    decoration: InputDecoration(
                      labelText: spec.label,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) =>
                        _emit(spec.key, value, debounce: true),
                  )
                : DropdownButtonFormField<String>(
                    initialValue: _values[spec.key] ?? '',
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: spec.label,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Все')),
                      for (final option in spec.options)
                        DropdownMenuItem(
                          value: option.value,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) => _emit(spec.key, value ?? ''),
                  ),
          ),
      ],
    );
  }
}

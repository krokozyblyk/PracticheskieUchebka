import 'package:flutter/material.dart';

import '../models/animal.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final String supplierName;

  const AnimalCard({
    super.key,
    required this.animal,
    this.supplierName = '—',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(animal.name.isNotEmpty ? animal.name[0] : '?'),
        ),
        title: Text(animal.name),
        subtitle: Text(
          '${animal.species} · ${animal.age} г. · '
          '${animal.price.toStringAsFixed(0)} ₽ · $supplierName',
        ),
        trailing: Text(
          '${animal.quantity} шт.',
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}

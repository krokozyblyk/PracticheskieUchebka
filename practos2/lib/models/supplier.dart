class Supplier {
  final int id;
  final String name;

  const Supplier({required this.id, required this.name});
}

const List<Supplier> suppliers = [
  Supplier(id: 1, name: 'ЗооМир'),
  Supplier(id: 2, name: 'Питомец+'),
  Supplier(id: 3, name: 'АкваДом'),
  Supplier(id: 4, name: 'Хвостик'),
];

String supplierName(int? id) {
  for (final s in suppliers) {
    if (s.id == id) return s.name;
  }
  return '—';
}

class Animal {
  final int id;
  final String name;
  final String species;
  final int age;
  final double price;
  final int supplierId;
  final List<int> categoryIds;
  final int quantity;
  final DateTime? deletedAt;

  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.price,
    required this.supplierId,
    required this.categoryIds,
    required this.quantity,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Animal copyWith({
    String? name,
    String? species,
    int? age,
    double? price,
    int? supplierId,
    List<int>? categoryIds,
    int? quantity,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Animal(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      age: age ?? this.age,
      price: price ?? this.price,
      supplierId: supplierId ?? this.supplierId,
      categoryIds: categoryIds ?? this.categoryIds,
      quantity: quantity ?? this.quantity,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}

import 'json_utils.dart';

class Animal {
  final int id;
  final String name;
  final String species;
  final String sku;
  final int age;
  final double price;
  final int supplierId;
  final List<int> categoryIds;
  final List<int> vetIds;
  final int quantity;
  final String description;
  final DateTime? deletedAt;

  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.sku,
    required this.age,
    required this.price,
    required this.supplierId,
    required this.categoryIds,
    required this.vetIds,
    required this.quantity,
    this.description = '',
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Animal copyWith({
    String? name,
    String? species,
    String? sku,
    int? age,
    double? price,
    int? supplierId,
    List<int>? categoryIds,
    List<int>? vetIds,
    int? quantity,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Animal(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      sku: sku ?? this.sku,
      age: age ?? this.age,
      price: price ?? this.price,
      supplierId: supplierId ?? this.supplierId,
      categoryIds: categoryIds ?? this.categoryIds,
      vetIds: vetIds ?? this.vetIds,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'sku': sku,
    'age': age,
    'price': price,
    'supplierId': supplierId,
    'categoryIds': categoryIds,
    'vetIds': vetIds,
    'quantity': quantity,
    'description': description,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
    id: asInt(json['id']),
    name: json['name'] as String? ?? '',
    species: json['species'] as String? ?? '',
    sku: json['sku'] as String? ?? '',
    age: asInt(json['age']),
    price: asDouble(json['price']),
    supplierId: json['supplierId'] != null
        ? asInt(json['supplierId'])
        : asIdOf(json['supplier']) ?? 0,
    categoryIds: json['categoryIds'] != null
        ? asIntList(json['categoryIds'])
        : asIdList(json['categories']),
    vetIds: json['vetIds'] != null
        ? asIntList(json['vetIds'])
        : asIdList(json['vets']),
    quantity: asInt(json['quantity']),
    description: json['description'] as String? ?? '',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.tryParse(json['deletedAt'] as String),
  );
}

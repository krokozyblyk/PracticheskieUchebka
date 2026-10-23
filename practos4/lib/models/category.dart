import 'json_utils.dart';

class Category {
  final int id;
  final String name;
  final String section;
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    required this.section,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Category copyWith({
    String? name,
    String? section,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      section: section ?? this.section,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'section': section,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: asInt(json['id']),
        name: json['name'] as String? ?? '',
        section: json['section'] as String? ?? '',
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.tryParse(json['deletedAt'] as String),
      );
}

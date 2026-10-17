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
}

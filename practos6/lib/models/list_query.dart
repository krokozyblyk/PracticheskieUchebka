class ListQuery {
  final String search;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;
  final Map<String, String> filters;

  const ListQuery({
    this.search = '',
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
    this.filters = const {},
  });

  ListQuery copyWith({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
    Map<String, String>? filters,
  }) {
    return ListQuery(
      search: search ?? this.search,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      filters: filters ?? this.filters,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ListQuery &&
      other.search == search &&
      other.sortField == sortField &&
      other.sortAscending == sortAscending &&
      other.page == page &&
      other.size == size &&
      other.includeDeleted == includeDeleted &&
      _sameFilters(other.filters, filters);

  @override
  int get hashCode => Object.hash(
    search,
    sortField,
    sortAscending,
    page,
    size,
    includeDeleted,
    Object.hashAll(
      filters.entries.map((entry) => '${entry.key}=${entry.value}'),
    ),
  );

  static bool _sameFilters(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

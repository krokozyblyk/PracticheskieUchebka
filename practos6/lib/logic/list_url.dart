import '../models/list_query.dart';

const _reserved = {'search', 'sort', 'dir', 'page', 'size', 'deleted'};

ListQuery listQueryFromParams(
  Map<String, String> params, {
  String defaultSort = 'name',
}) {
  final filters = <String, String>{
    for (final entry in params.entries)
      if (!_reserved.contains(entry.key) && entry.value.trim().isNotEmpty)
        entry.key: entry.value.trim(),
  };
  return ListQuery(
    search: params['search'] ?? '',
    sortField: params['sort'] ?? defaultSort,
    sortAscending: params['dir'] != 'desc',
    page: int.tryParse(params['page'] ?? '') ?? 1,
    size: int.tryParse(params['size'] ?? '') ?? 10,
    includeDeleted: params['deleted'] == 'true',
    filters: filters,
  );
}

Map<String, String> listQueryToParams(ListQuery query) {
  final params = <String, String>{
    if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
    if (query.sortField != 'name') 'sort': query.sortField,
    if (!query.sortAscending) 'dir': 'desc',
    if (query.page != 1) 'page': '${query.page}',
    if (query.size != 10) 'size': '${query.size}',
    if (query.includeDeleted) 'deleted': 'true',
    ...query.filters,
  };
  return params;
}

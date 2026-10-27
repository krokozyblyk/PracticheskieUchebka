import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/list_query.dart';
import '../models/page_result.dart';

abstract class ApiRepositoryBase<T> {
  ApiRepositoryBase(
    this.dio, {
    required this.path,
    required this.fromJson,
    required this.toJson,
    this.cacheReferenceList = false,
  });

  final Dio dio;
  final String path;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final bool cacheReferenceList;

  CancelToken? _pageToken;
  PageResult<T>? _referenceCache;

  Map<String, dynamic> listParams(ListQuery query) => {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        'sort': '${query.sortField},${query.sortAscending ? 'asc' : 'desc'}',
        'page': query.page,
        'size': query.size,
        if (query.includeDeleted) 'includeDeleted': true,
      };

  PageResult<T> pageFrom(Map<String, dynamic> data) {
    final rawItems = data['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) => fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <T>[];
    return PageResult<T>(
      items: items,
      page: data['page'] as int? ?? 1,
      size: data['size'] as int? ?? items.length,
      total: data['total'] as int? ?? items.length,
    );
  }

  Future<PageResult<T>> fetchPage(
    Map<String, dynamic> params, {
    bool reference = false,
    bool cancellable = true,
  }) async {
    if (cacheReferenceList && reference && _referenceCache != null) {
      return _referenceCache!;
    }

    final token = cancellable && !reference ? CancelToken() : null;
    if (token != null) {
      _pageToken?.cancel();
      _pageToken = token;
    }

    try {
      final result = await retryRead(
        () => guard(() async {
          final response = await dio.get(
            '/$path',
            queryParameters: params,
            cancelToken: token,
          );
          return pageFrom(Map<String, dynamic>.from(response.data as Map));
        }),
      );
      if (cacheReferenceList && reference) _referenceCache = result;
      return result;
    } finally {
      if (identical(_pageToken, token)) _pageToken = null;
    }
  }

  void invalidateReferenceCache() {
    _referenceCache = null;
  }

  Future<T?> findById(int id) async {
    try {
      return await retryRead(
        () => guard(() async {
          final response = await dio.get('/$path/$id');
          return fromJson(Map<String, dynamic>.from(response.data as Map));
        }),
      );
    } on NotFoundException {
      return null;
    }
  }

  Future<T> create(T item) async {
    final result = await guard(() async {
      final response = await dio.post('/$path', data: toJson(item));
      return fromJson(Map<String, dynamic>.from(response.data as Map));
    });
    invalidateReferenceCache();
    return result;
  }

  Future<T> update(T item) async {
    final id = (toJson(item)['id'] as num?)?.toInt() ?? 0;
    final result = await guard(() async {
      final response = await dio.put('/$path/$id', data: toJson(item));
      return fromJson(Map<String, dynamic>.from(response.data as Map));
    });
    invalidateReferenceCache();
    return result;
  }

  Future<void> softDelete(int id) async {
    await guard(() => dio.delete('/$path/$id'));
    invalidateReferenceCache();
  }

  Future<void> hardDelete(int id) async {
    await guard(
      () => dio.delete('/$path/$id', queryParameters: {'hard': true}),
    );
    invalidateReferenceCache();
  }

  Future<void> restore(int id) async {
    await guard(() => dio.post('/$path/$id/restore'));
    invalidateReferenceCache();
  }

  Future<int> deleteMany(List<int> ids) async {
    final result = await guard(() async {
      final response = await dio.post(
        '/$path/bulk-delete',
        data: {'ids': ids},
      );
      return (response.data as Map<String, dynamic>)['deleted'] as int? ?? 0;
    });
    invalidateReferenceCache();
    return result;
  }

  Future<int> hardDeleteMany(List<int> ids) async {
    final result = await guard(() async {
      final response = await dio.post(
        '/$path/bulk-delete',
        data: {'ids': ids, 'hard': true},
      );
      return (response.data as Map<String, dynamic>)['deleted'] as int? ?? 0;
    });
    invalidateReferenceCache();
    return result;
  }

  Future<int> restoreMany(List<int> ids) async {
    final result = await guard(() async {
      final response = await dio.post(
        '/$path/bulk-restore',
        data: {'ids': ids},
      );
      return (response.data as Map<String, dynamic>)['restored'] as int? ?? 0;
    });
    invalidateReferenceCache();
    return result;
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/list_url.dart';
import '../models/list_query.dart';

class QueryUrlSync extends StatefulWidget {
  final String path;
  final Listenable listenable;
  final ListQuery Function() queryOf;
  final Widget child;

  const QueryUrlSync({
    super.key,
    required this.path,
    required this.listenable,
    required this.queryOf,
    required this.child,
  });

  @override
  State<QueryUrlSync> createState() => _QueryUrlSyncState();
}

class _QueryUrlSyncState extends State<QueryUrlSync> {
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final params = listQueryToParams(widget.queryOf());
      final target = Uri(
        path: widget.path,
        queryParameters: params.isEmpty ? null : params,
      ).toString();
      final current = GoRouterState.of(context).uri.toString();
      if (current != target) {
        GoRouter.of(context).replace(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

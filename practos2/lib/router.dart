import 'package:go_router/go_router.dart';

import 'screens/animal_detail_screen.dart';
import 'screens/animal_list_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/not_found_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) =>
          AnimalListScreen(queryParameters: state.uri.queryParameters),
    ),
    GoRoute(
      path: '/animals',
      name: 'animals',
      builder: (context, state) =>
          AnimalListScreen(queryParameters: state.uri.queryParameters),
    ),
    GoRoute(
      path: '/animals/:id',
      name: 'animalDetail',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AnimalDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoryListScreen(),
    ),
  ],
  errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),
);

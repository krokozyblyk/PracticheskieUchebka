import 'package:go_router/go_router.dart';

import 'screens/animal_detail_screen.dart';
import 'screens/animal_form_screen.dart';
import 'screens/animal_list_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/category_form_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/customer_detail_screen.dart';
import 'screens/customer_form_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/supplier_detail_screen.dart';
import 'screens/supplier_form_screen.dart';
import 'screens/supplier_list_screen.dart';
import 'screens/vet_detail_screen.dart';
import 'screens/vet_form_screen.dart';
import 'screens/vet_list_screen.dart';

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
      path: '/animals/new',
      name: 'animalCreate',
      builder: (context, state) => const AnimalFormScreen(),
    ),
    GoRoute(
      path: '/animals/:id',
      name: 'animalDetail',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return AnimalDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/animals/:id/edit',
      name: 'animalEdit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return AnimalFormScreen(id: id);
      },
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoryListScreen(),
    ),
    GoRoute(
      path: '/categories/new',
      name: 'categoryCreate',
      builder: (context, state) => const CategoryFormScreen(),
    ),
    GoRoute(
      path: '/categories/:id',
      name: 'categoryDetail',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return CategoryDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/categories/:id/edit',
      name: 'categoryEdit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return CategoryFormScreen(id: id);
      },
    ),
    GoRoute(
      path: '/suppliers',
      name: 'suppliers',
      builder: (context, state) => const SupplierListScreen(),
    ),
    GoRoute(
      path: '/suppliers/new',
      name: 'supplierCreate',
      builder: (context, state) => const SupplierFormScreen(),
    ),
    GoRoute(
      path: '/suppliers/:id',
      name: 'supplierDetail',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return SupplierDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/suppliers/:id/edit',
      name: 'supplierEdit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return SupplierFormScreen(id: id);
      },
    ),
    GoRoute(
      path: '/vets',
      name: 'vets',
      builder: (context, state) => const VetListScreen(),
    ),
    GoRoute(
      path: '/vets/new',
      name: 'vetCreate',
      builder: (context, state) => const VetFormScreen(),
    ),
    GoRoute(
      path: '/vets/:id',
      name: 'vetDetail',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return VetDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/vets/:id/edit',
      name: 'vetEdit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return VetFormScreen(id: id);
      },
    ),
    GoRoute(
      path: '/customers',
      name: 'customers',
      builder: (context, state) => const CustomerListScreen(),
    ),
    GoRoute(
      path: '/customers/new',
      name: 'customerCreate',
      builder: (context, state) => const CustomerFormScreen(),
    ),
    GoRoute(
      path: '/customers/:id',
      name: 'customerDetail',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return CustomerDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/customers/:id/edit',
      name: 'customerEdit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return CustomerFormScreen(id: id);
      },
    ),
  ],
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
);

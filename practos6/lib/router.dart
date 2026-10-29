import 'package:go_router/go_router.dart';

import 'logic/permissions.dart';
import 'screens/animal_detail_screen.dart';
import 'screens/animal_form_screen.dart';
import 'screens/animal_list_screen.dart';
import 'screens/appointment_detail_screen.dart';
import 'screens/appointment_form_screen.dart';
import 'screens/appointment_list_screen.dart';
import 'screens/category_detail_screen.dart';
import 'screens/category_form_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/customer_detail_screen.dart';
import 'screens/customer_form_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forbidden_screen.dart';
import 'screens/login_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/order_form_screen.dart';
import 'screens/order_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/review_detail_screen.dart';
import 'screens/review_form_screen.dart';
import 'screens/review_list_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/supplier_detail_screen.dart';
import 'screens/supplier_form_screen.dart';
import 'screens/supplier_list_screen.dart';
import 'screens/users_screen.dart';
import 'screens/vet_detail_screen.dart';
import 'screens/vet_form_screen.dart';
import 'screens/vet_list_screen.dart';
import 'state/auth_notifier.dart';

GoRouter buildRouter(AuthNotifier auth) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: auth,
    redirect: (context, state) {
      final target = state.matchedLocation;
      final loggedIn = auth.isAuthenticated;
      final isPublic = target == '/login' || target == '/register';

      if (!loggedIn) {
        if (isPublic) return null;
        final from = Uri.encodeComponent(state.uri.toString());
        return '/login?from=$from';
      }

      if (isPublic) return '/dashboard';
      if (target == '/') return '/dashboard';

      final user = auth.user;
      if (user == null) return '/login';
      if (!canOpenPath(user.role, target)) return '/forbidden';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/forbidden',
        name: 'forbidden',
        builder: (context, state) => const ForbiddenScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
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
        builder: (context, state) =>
            CategoryListScreen(queryParameters: state.uri.queryParameters),
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
        builder: (context, state) =>
            SupplierListScreen(queryParameters: state.uri.queryParameters),
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
        builder: (context, state) =>
            VetListScreen(queryParameters: state.uri.queryParameters),
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
        builder: (context, state) =>
            CustomerListScreen(queryParameters: state.uri.queryParameters),
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
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) =>
            OrderListScreen(queryParameters: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/orders/new',
        name: 'orderCreate',
        builder: (context, state) => const OrderFormScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'orderDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return OrderDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/orders/:id/edit',
        name: 'orderEdit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return OrderFormScreen(id: id);
        },
      ),
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) =>
            AppointmentListScreen(queryParameters: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/appointments/new',
        name: 'appointmentCreate',
        builder: (context, state) => const AppointmentFormScreen(),
      ),
      GoRoute(
        path: '/appointments/:id',
        name: 'appointmentDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return AppointmentDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/appointments/:id/edit',
        name: 'appointmentEdit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return AppointmentFormScreen(id: id);
        },
      ),
      GoRoute(
        path: '/reviews',
        name: 'reviews',
        builder: (context, state) =>
            ReviewListScreen(queryParameters: state.uri.queryParameters),
      ),
      GoRoute(
        path: '/reviews/new',
        name: 'reviewCreate',
        builder: (context, state) => const ReviewFormScreen(),
      ),
      GoRoute(
        path: '/reviews/:id',
        name: 'reviewDetail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ReviewDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/reviews/:id/edit',
        name: 'reviewEdit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return ReviewFormScreen(id: id);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        NotFoundScreen(location: state.uri.toString()),
  );
}

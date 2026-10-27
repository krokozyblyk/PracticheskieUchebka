import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api_client.dart';
import 'core/auth_api.dart';
import 'models/category.dart';
import 'models/customer.dart';
import 'models/supplier.dart';
import 'models/vet.dart';
import 'repositories/animal_repository.dart';
import 'repositories/api_animal_repository.dart';
import 'repositories/api_category_repository.dart';
import 'repositories/api_customer_repository.dart';
import 'repositories/api_supplier_repository.dart';
import 'repositories/api_vet_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/supplier_repository.dart';
import 'repositories/vet_repository.dart';
import 'state/animal_list_notifier.dart';
import 'state/auth_notifier.dart';
import 'state/entity_list_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();

  late final AuthNotifier auth;
  final dio = buildDio(
    tokenProvider: () => auth.accessToken,
    onUnauthorized: () => auth.refreshTokens(),
    onAuthFailed: () => auth.logout(
      message: 'Сессия истекла. Войдите снова.',
    ),
  );
  final authApi = AuthApi(dio);
  auth = AuthNotifier(prefs, authApi);
  await auth.restore();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: dio),
        Provider.value(value: authApi),
        ChangeNotifierProvider.value(value: auth),
        Provider<AnimalRepository>(create: (_) => ApiAnimalRepository(dio)),
        Provider<CategoryRepository>(create: (_) => ApiCategoryRepository(dio)),
        Provider<SupplierRepository>(create: (_) => ApiSupplierRepository(dio)),
        Provider<VetRepository>(create: (_) => ApiVetRepository(dio)),
        Provider<CustomerRepository>(create: (_) => ApiCustomerRepository(dio)),
        ChangeNotifierProvider<AnimalListNotifier>(
          create: (context) =>
              AnimalListNotifier(context.read<AnimalRepository>()),
        ),
        ChangeNotifierProvider<EntityListNotifier<Category>>(
          create: (context) =>
              EntityListNotifier<Category>(context.read<CategoryRepository>()),
        ),
        ChangeNotifierProvider<EntityListNotifier<Supplier>>(
          create: (context) =>
              EntityListNotifier<Supplier>(context.read<SupplierRepository>()),
        ),
        ChangeNotifierProvider<EntityListNotifier<Vet>>(
          create: (context) =>
              EntityListNotifier<Vet>(context.read<VetRepository>()),
        ),
        ChangeNotifierProvider<EntityListNotifier<Customer>>(
          create: (context) =>
              EntityListNotifier<Customer>(context.read<CustomerRepository>()),
        ),
      ],
      child: const ZooApp(),
    ),
  );
}

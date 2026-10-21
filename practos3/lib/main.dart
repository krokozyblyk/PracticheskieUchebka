import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'models/category.dart';
import 'models/customer.dart';
import 'models/supplier.dart';
import 'models/vet.dart';
import 'repositories/animal_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/persistent_animal_repository.dart';
import 'repositories/persistent_category_repository.dart';
import 'repositories/persistent_customer_repository.dart';
import 'repositories/persistent_supplier_repository.dart';
import 'repositories/persistent_vet_repository.dart';
import 'repositories/supplier_repository.dart';
import 'repositories/vet_repository.dart';
import 'state/animal_list_notifier.dart';
import 'state/entity_list_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<AnimalRepository>(
          create: (_) => PersistentAnimalRepository(preferences),
        ),
        Provider<CategoryRepository>(
          create: (_) => PersistentCategoryRepository(preferences),
        ),
        Provider<SupplierRepository>(
          create: (_) => PersistentSupplierRepository(preferences),
        ),
        Provider<VetRepository>(
          create: (_) => PersistentVetRepository(preferences),
        ),
        Provider<CustomerRepository>(
          create: (_) => PersistentCustomerRepository(preferences),
        ),
        ChangeNotifierProvider<AnimalListNotifier>(
          create: (context) =>
              AnimalListNotifier(context.read<AnimalRepository>())..load(),
        ),
        ChangeNotifierProvider<EntityListNotifier<Category>>(
          create: (context) =>
              EntityListNotifier<Category>(context.read<CategoryRepository>())
                ..load(),
        ),
        ChangeNotifierProvider<EntityListNotifier<Supplier>>(
          create: (context) =>
              EntityListNotifier<Supplier>(context.read<SupplierRepository>())
                ..load(),
        ),
        ChangeNotifierProvider<EntityListNotifier<Vet>>(
          create: (context) =>
              EntityListNotifier<Vet>(context.read<VetRepository>())..load(),
        ),
        ChangeNotifierProvider<EntityListNotifier<Customer>>(
          create: (context) =>
              EntityListNotifier<Customer>(context.read<CustomerRepository>())
                ..load(),
        ),
      ],
      child: const ZooApp(),
    ),
  );
}

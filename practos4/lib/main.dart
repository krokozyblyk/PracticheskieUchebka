import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/api_client.dart';
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
import 'state/entity_list_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final dio = buildDio();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: dio),
        Provider<AnimalRepository>(create: (_) => ApiAnimalRepository(dio)),
        Provider<CategoryRepository>(create: (_) => ApiCategoryRepository(dio)),
        Provider<SupplierRepository>(create: (_) => ApiSupplierRepository(dio)),
        Provider<VetRepository>(create: (_) => ApiVetRepository(dio)),
        Provider<CustomerRepository>(create: (_) => ApiCustomerRepository(dio)),
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

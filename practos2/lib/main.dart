import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'repositories/animal_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/in_memory_animal_repository.dart';
import 'repositories/in_memory_category_repository.dart';
import 'state/animal_list_notifier.dart';
import 'state/category_list_notifier.dart';

void main() {
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        Provider<AnimalRepository>(
          create: (_) => InMemoryAnimalRepository(),
        ),
        Provider<CategoryRepository>(
          create: (_) => InMemoryCategoryRepository(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AnimalListNotifier(context.read<AnimalRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CategoryListNotifier(context.read<CategoryRepository>())..load(),
        ),
      ],
      child: const ZooApp(),
    ),
  );
}

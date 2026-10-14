import 'package:go_router/go_router.dart';

import 'screens/calculator_screen.dart';
import 'screens/calculation_result_screen.dart';
import 'screens/converter_result_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/calculator',
      name: 'calculator',
      builder: (context, state) => const CalculatorScreen(),
      routes: [
        GoRoute(
          path: 'result',
          name: 'calculatorResult',
          builder: (context, state) {
            final uri = state.uri;
            return CalculationResultScreen(
              query: uri.queryParameters,
              location: uri.toString(),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/converter',
      name: 'converter',
      builder: (context, state) => const ConverterScreen(),
      routes: [
        GoRoute(
          path: 'result',
          name: 'converterResult',
          builder: (context, state) {
            final uri = state.uri;
            return ConverterResultScreen(
              query: uri.queryParameters,
              location: uri.toString(),
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),
);

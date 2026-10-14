import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practos1/app_settings.dart';
import 'package:practos1/router.dart';
import 'package:practos1/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('калькулятор и конвертер переходят по адресу', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.load();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: appRouter,
        theme: buildAppTheme(brightness: Brightness.light),
        darkTheme: buildAppTheme(brightness: Brightness.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Калькулятор'), findsOneWidget);
    expect(find.text('Конвертер валют'), findsOneWidget);

    await tester.tap(find.text('Калькулятор'));
    await tester.pumpAndSettle();

    expect(find.text('Первое число'), findsOneWidget);
    expect(find.text('Второе число'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '12');
    await tester.enterText(find.byType(TextFormField).at(1), '4');
    await tester.tap(find.text('Вычислить'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/calculator/result');
    expect(appRouter.state.uri.queryParameters['a'], '12');
    expect(appRouter.state.uri.queryParameters['op'], '+');
    expect(appRouter.state.uri.queryParameters['b'], '4');
    expect(find.text('16'), findsOneWidget);

    await tester.tap(find.text('Вернуться к калькулятору'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, '/calculator');

    await tester.enterText(find.byType(TextFormField).at(0), '9');
    await tester.enterText(find.byType(TextFormField).at(1), '0');
    await tester.tap(find.byIcon(Icons.arrow_drop_down).last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Деление').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вычислить'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/calculator/result');
    expect(find.text('Деление на ноль невозможно'), findsOneWidget);

    await tester.tap(find.text('На главную'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, '/');

    await tester.tap(find.text('Конвертер валют'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '100');
    await tester.tap(find.text('Конвертировать'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/converter/result');
    expect(appRouter.state.uri.queryParameters['from'], 'USD');
    expect(appRouter.state.uri.queryParameters['to'], 'RUB');
    expect(appRouter.state.uri.queryParameters['sum'], '100');
    expect(find.textContaining('9250.00'), findsOneWidget);
  });

  testWidgets('пустые поля не запускают переход', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppSettings.load();

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: appRouter,
        theme: buildAppTheme(brightness: Brightness.light),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Калькулятор'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вычислить'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/calculator');
    expect(find.text('Введите число'), findsWidgets);
  });
}
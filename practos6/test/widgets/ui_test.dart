import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practos6/core/auth_api.dart';
import 'package:practos6/logic/permissions.dart';
import 'package:practos6/logic/validators.dart';
import 'package:practos6/models/app_user.dart';
import 'package:practos6/models/page_result.dart';
import 'package:practos6/models/role.dart';
import 'package:practos6/state/auth_notifier.dart';
import 'package:practos6/state/list_controller.dart';
import 'package:practos6/state/load_status.dart';
import 'package:practos6/theme.dart';
import 'package:practos6/widgets/entity_form.dart';
import 'package:practos6/widgets/entity_table.dart';
import 'package:practos6/widgets/list_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAuth extends AuthNotifier {
  TestAuth(this.testUser, SharedPreferences prefs)
    : super(prefs, AuthApi(Dio()));

  final AppUser? testUser;

  @override
  AppUser? get user => testUser;

  @override
  bool get isAuthenticated => testUser != null;

  @override
  bool can(Permission permission) =>
      testUser != null && testUser!.role.can(permission);
}

class FakeController extends ChangeNotifier
    implements PagedListController<Object> {
  FakeController({
    this.status = LoadStatus.success,
    PageResult<Object>? result,
    this.error,
  }) : result = result ?? PageResult<Object>.empty();

  @override
  LoadStatus status;

  @override
  PageResult<Object> result;

  @override
  String? error;

  int loadCalls = 0;

  @override
  Set<int> selected = {};

  @override
  bool hasSelection = false;

  @override
  bool includeDeleted = false;

  @override
  String search = '';

  @override
  String sortField = 'name';

  @override
  bool sortAscending = true;

  @override
  Future<void> load() async {
    loadCalls += 1;
  }

  @override
  Future<void> deleteOne(int id) async {}

  @override
  Future<void> deleteSelected() async {}

  @override
  Future<void> goToPage(int page) async {}

  @override
  Future<void> hardDeleteOne(int id) async {}

  @override
  Future<void> hardDeleteSelected() async {}

  @override
  Future<void> restoreOne(int id) async {}

  @override
  Future<void> restoreSelected() async {}

  @override
  Future<void> setIncludeDeleted(bool value) async {}

  @override
  Future<void> setSearch(String value) async {}

  @override
  Future<void> setSize(int size) async {}

  @override
  Future<void> sortBy(String field) async {}

  @override
  void toggleSelection(int id) {}
}

Widget wrap(Widget child, AuthNotifier auth) {
  return ChangeNotifierProvider<AuthNotifier>.value(
    value: auth,
    child: MaterialApp(theme: buildAppTheme(), home: child),
  );
}

ListScaffold<Object> scaffold(FakeController controller, String createLabel) {
  return ListScaffold<Object>(
    title: 'Категории',
    currentPath: '/categories',
    controller: controller,
    idOf: (item) => 0,
    isDeleted: (item) => false,
    createLabel: createLabel,
    onCreate: (context) {},
    onOpen: (context, item) {},
    onEdit: (context, item) {},
    columns: [
      TableColumnSpec(label: 'Название', build: (item) => const Text('Тест')),
    ],
  );
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  TestAuth authFor(Role role) => TestAuth(
    AppUser(
      id: 1,
      username: 'test',
      fullName: 'Тестовый Пользователь',
      email: 'test@zoo.local',
      role: role,
    ),
    prefs,
  );

  testWidgets('список показывает состояние загрузки', (tester) async {
    final controller = FakeController(status: LoadStatus.loading);
    await tester.pumpWidget(
      wrap(
        scaffold(controller, 'Добавить категорию'),
        authFor(Role.specialist),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('список показывает пустой результат', (tester) async {
    final controller = FakeController();
    await tester.pumpWidget(
      wrap(
        scaffold(controller, 'Добавить категорию'),
        authFor(Role.specialist),
      ),
    );
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('ошибка показывает кнопку повтора', (tester) async {
    final controller = FakeController(
      status: LoadStatus.error,
      error: 'Сервер недоступен',
    );
    await tester.pumpWidget(
      wrap(
        scaffold(controller, 'Добавить категорию'),
        authFor(Role.specialist),
      ),
    );
    expect(find.text('Сервер недоступен'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    await tester.pump();
    expect(controller.loadCalls, 1);
  });

  testWidgets('форма не отправляется с пустым обязательным полем', (
    tester,
  ) async {
    var submitted = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: EntityForm(
            fields: [
              TextFieldSpec(
                key: 'name',
                label: 'Название',
                validator: (value) => requiredValidator(value),
              ),
            ],
            submitLabel: 'Создать',
            onSubmit: () async => submitted = true,
            onCancel: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.text('Создать'));
    await tester.pump();
    expect(find.text('Обязательное поле'), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('кнопка создания скрыта покупателю', (tester) async {
    final controller = FakeController();
    await tester.pumpWidget(
      wrap(scaffold(controller, 'Добавить категорию'), authFor(Role.customer)),
    );
    expect(find.text('Добавить категорию'), findsNothing);
  });

  testWidgets('кнопка создания видна специалисту', (tester) async {
    final controller = FakeController();
    await tester.pumpWidget(
      wrap(
        scaffold(controller, 'Добавить категорию'),
        authFor(Role.specialist),
      ),
    );
    expect(find.text('Добавить категорию'), findsOneWidget);
  });

  testWidgets('на ширине 360 используется нижняя навигация', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = FakeController();
    await tester.pumpWidget(
      wrap(
        scaffold(controller, 'Добавить категорию'),
        authFor(Role.specialist),
      ),
    );
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });
}

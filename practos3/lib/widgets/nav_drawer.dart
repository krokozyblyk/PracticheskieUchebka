import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavDrawer extends StatelessWidget {
  final String currentPath;

  const NavDrawer({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2E7D32)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Зоомагазин',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          _item(context, Icons.pets_outlined, 'Животные', '/animals'),
          _item(context, Icons.category_outlined, 'Категории', '/categories'),
          _item(context, Icons.local_shipping_outlined, 'Поставщики',
              '/suppliers'),
          _item(context, Icons.medical_services_outlined, 'Ветеринары',
              '/vets'),
          _item(context, Icons.people_outline, 'Покупатели', '/customers'),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String path,
  ) {
    final selected = currentPath == path ||
        (path == '/animals' && currentPath == '/');
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selected,
      onTap: () {
        Navigator.pop(context);
        context.go(path);
      },
    );
  }
}

AppBar navAppBar(
  BuildContext context,
  String title, {
  List<Widget> actions = const [],
}) {
  return AppBar(
    title: Text(title),
    actions: actions,
  );
}

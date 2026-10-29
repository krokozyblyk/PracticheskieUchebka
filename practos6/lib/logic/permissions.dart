import '../models/role.dart';

enum Permission {
  viewCatalog,
  manageCatalog,
  deleteSoft,
  deleteHard,
  restore,
  manageUsers,
  viewStats,
  viewProfile,
  manageOrders,
  manageAppointments,
  manageReviews,
}

extension RolePermissions on Role {
  Set<Permission> get permissions => switch (this) {
    Role.customer => {
      Permission.viewCatalog,
      Permission.viewProfile,
      Permission.manageReviews,
    },
    Role.specialist => {
      Permission.viewCatalog,
      Permission.manageCatalog,
      Permission.deleteSoft,
      Permission.manageOrders,
      Permission.manageAppointments,
    },
    Role.admin => {
      Permission.viewCatalog,
      Permission.deleteHard,
      Permission.restore,
      Permission.manageUsers,
      Permission.viewStats,
    },
  };

  bool can(Permission permission) => permissions.contains(permission);
}

bool canOpenPath(Role role, String path) {
  if (path.startsWith('/orders')) return role.can(Permission.manageOrders);
  if (path.startsWith('/appointments')) {
    return role.can(Permission.manageAppointments);
  }
  if (path.startsWith('/reviews')) return role.can(Permission.manageReviews);
  if (path == '/users' || path == '/statistics') {
    return role.can(Permission.manageUsers);
  }
  if (path == '/profile') return role.can(Permission.viewProfile);
  if (path.endsWith('/new') || path.endsWith('/edit')) {
    return role.can(Permission.manageCatalog);
  }
  return true;
}

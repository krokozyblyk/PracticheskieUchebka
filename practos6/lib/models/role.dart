enum Role {
  customer('customer', 'Покупатель'),
  specialist('specialist', 'Специалист'),
  admin('admin', 'Администратор');

  const Role(this.code, this.label);

  final String code;
  final String label;

  static Role fromCode(String? code) {
    for (final role in Role.values) {
      if (role.code == code) return role;
    }
    return Role.customer;
  }
}

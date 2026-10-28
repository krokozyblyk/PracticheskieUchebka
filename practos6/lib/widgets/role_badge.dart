import 'package:flutter/material.dart';

import '../models/role.dart';

Color roleColor(Role role) => switch (role) {
  Role.customer => const Color(0xFF81C784),
  Role.specialist => const Color(0xFF64B5F6),
  Role.admin => const Color(0xFFEF9A9A),
};

class RoleBadge extends StatelessWidget {
  final Role role;
  final bool dense;

  const RoleBadge({super.key, required this.role, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final color = roleColor(role);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        role.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: dense ? 9 : 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

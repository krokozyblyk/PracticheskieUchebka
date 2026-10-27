import 'json_utils.dart';

class Vet {
  final int id;
  final String fullName;
  final int specializationCategoryId;
  final String phone;
  final String email;
  final DateTime? deletedAt;

  const Vet({
    required this.id,
    required this.fullName,
    required this.specializationCategoryId,
    this.phone = '',
    this.email = '',
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Vet copyWith({
    String? fullName,
    int? specializationCategoryId,
    String? phone,
    String? email,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Vet(
      id: id,
      fullName: fullName ?? this.fullName,
      specializationCategoryId:
          specializationCategoryId ?? this.specializationCategoryId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'specializationCategoryId': specializationCategoryId,
        'phone': phone,
        'email': email,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Vet.fromJson(Map<String, dynamic> json) => Vet(
        id: asInt(json['id']),
        fullName: json['fullName'] as String? ?? '',
        specializationCategoryId: asInt(json['specializationCategoryId']),
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.tryParse(json['deletedAt'] as String),
      );
}

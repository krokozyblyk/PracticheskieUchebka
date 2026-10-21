import 'json_utils.dart';
import 'loyalty_card.dart';

class Customer {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final LoyaltyCard? loyaltyCard;
  final DateTime? deletedAt;

  const Customer({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.address = '',
    this.loyaltyCard,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Customer copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
    LoyaltyCard? loyaltyCard,
    bool clearLoyaltyCard = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Customer(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      loyaltyCard:
          clearLoyaltyCard ? null : (loyaltyCard ?? this.loyaltyCard),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'address': address,
        'loyaltyCard': loyaltyCard?.toJson(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) {
    final card = json['loyaltyCard'];
    return Customer(
      id: asInt(json['id']),
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      loyaltyCard: card is Map<String, dynamic>
          ? LoyaltyCard.fromJson(card)
          : card is Map
              ? LoyaltyCard.fromJson(Map<String, dynamic>.from(card))
              : null,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.tryParse(json['deletedAt'] as String),
    );
  }
}

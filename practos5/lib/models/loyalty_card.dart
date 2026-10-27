import 'json_utils.dart';

class LoyaltyCard {
  final String cardNumber;
  final DateTime issuedAt;
  final int discountPercent;
  final bool active;

  const LoyaltyCard({
    required this.cardNumber,
    required this.issuedAt,
    required this.discountPercent,
    this.active = true,
  });

  LoyaltyCard copyWith({
    String? cardNumber,
    DateTime? issuedAt,
    int? discountPercent,
    bool? active,
  }) {
    return LoyaltyCard(
      cardNumber: cardNumber ?? this.cardNumber,
      issuedAt: issuedAt ?? this.issuedAt,
      discountPercent: discountPercent ?? this.discountPercent,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
        'cardNumber': cardNumber,
        'issuedAt': issuedAt.toIso8601String(),
        'discountPercent': discountPercent,
        'active': active,
      };

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
        cardNumber: json['cardNumber'] as String? ?? '',
        issuedAt: json['issuedAt'] == null
            ? DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.tryParse(json['issuedAt'] as String) ??
                DateTime.fromMillisecondsSinceEpoch(0),
        discountPercent: asInt(json['discountPercent']),
        active: json['active'] as bool? ?? true,
      );
}

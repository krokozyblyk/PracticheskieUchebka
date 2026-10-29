class Order {
  final int id;
  final int customerId;
  final int animalId;
  final String customerName;
  final String animalName;
  final int quantity;
  final double unitPrice;
  final int discountPercent;
  final double total;
  final String status;
  final String notes;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.animalId,
    this.customerName = '',
    this.animalName = '',
    required this.quantity,
    this.unitPrice = 0,
    this.discountPercent = 0,
    this.total = 0,
    this.status = 'new',
    this.notes = '',
    this.createdAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'animalId': animalId,
    'quantity': quantity,
    'status': status,
    'notes': notes,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: (json['id'] as num?)?.toInt() ?? 0,
    customerId: (json['customerId'] as num?)?.toInt() ?? 0,
    animalId: (json['animalId'] as num?)?.toInt() ?? 0,
    customerName: json['customerName'] as String? ?? '',
    animalName: json['animalName'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
    discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'new',
    notes: json['notes'] as String? ?? '',
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.tryParse(json['createdAt'] as String),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.tryParse(json['deletedAt'] as String),
  );
}

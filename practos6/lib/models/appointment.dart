class Appointment {
  final int id;
  final int customerId;
  final int animalId;
  final int vetId;
  final String customerName;
  final String animalName;
  final String vetName;
  final DateTime? scheduledAt;
  final int durationMinutes;
  final String status;
  final String notes;
  final DateTime? deletedAt;

  const Appointment({
    required this.id,
    required this.customerId,
    required this.animalId,
    required this.vetId,
    this.customerName = '',
    this.animalName = '',
    this.vetName = '',
    this.scheduledAt,
    this.durationMinutes = 30,
    this.status = 'planned',
    this.notes = '',
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'animalId': animalId,
    'vetId': vetId,
    'scheduledAt': scheduledAt?.toIso8601String(),
    'durationMinutes': durationMinutes,
    'status': status,
    'notes': notes,
  };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: (json['id'] as num?)?.toInt() ?? 0,
    customerId: (json['customerId'] as num?)?.toInt() ?? 0,
    animalId: (json['animalId'] as num?)?.toInt() ?? 0,
    vetId: (json['vetId'] as num?)?.toInt() ?? 0,
    customerName: json['customerName'] as String? ?? '',
    animalName: json['animalName'] as String? ?? '',
    vetName: json['vetName'] as String? ?? '',
    scheduledAt: json['scheduledAt'] == null
        ? null
        : DateTime.tryParse(json['scheduledAt'] as String),
    durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
    status: json['status'] as String? ?? 'planned',
    notes: json['notes'] as String? ?? '',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.tryParse(json['deletedAt'] as String),
  );
}

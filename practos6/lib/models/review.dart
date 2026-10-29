class Review {
  final int id;
  final int userId;
  final int animalId;
  final String userName;
  final String animalName;
  final int rating;
  final String text;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  const Review({
    required this.id,
    required this.userId,
    required this.animalId,
    this.userName = '',
    this.animalName = '',
    required this.rating,
    this.text = '',
    this.createdAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'animalId': animalId,
    'rating': rating,
    'text': text,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: (json['id'] as num?)?.toInt() ?? 0,
    userId: (json['userId'] as num?)?.toInt() ?? 0,
    animalId: (json['animalId'] as num?)?.toInt() ?? 0,
    userName: json['userName'] as String? ?? '',
    animalName: json['animalName'] as String? ?? '',
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    text: json['text'] as String? ?? '',
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.tryParse(json['createdAt'] as String),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.tryParse(json['deletedAt'] as String),
  );
}

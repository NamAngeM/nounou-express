class ReviewModel {
  final String id, bookingId, fromUserId, toUserId, comment;
  final double rating;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingId': bookingId,
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] as String? ?? '',
    bookingId: json['bookingId'] as String? ?? '',
    fromUserId: json['fromUserId'] as String? ?? '',
    toUserId: json['toUserId'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    comment: json['comment'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

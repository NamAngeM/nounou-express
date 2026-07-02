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
}

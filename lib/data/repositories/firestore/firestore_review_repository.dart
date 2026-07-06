import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/review_model.dart';
import '../review_repository.dart';
import 'firestore_helpers.dart';

/// Implémentation Firestore des avis.
///
/// Schéma : `reviews/{reviewId}` (ReviewModel.toJson, dates ISO-8601).
/// Id déterministe `bookingId_fromUserId` : un nouvel avis sur la même
/// réservation remplace le précédent (idempotent).
class FirestoreReviewRepository implements ReviewRepository {
  FirestoreReviewRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  String _docId(String bookingId, String fromUserId) =>
      '${bookingId}_$fromUserId';

  @override
  Future<void> addReview(ReviewModel review) => _reviews
      .doc(_docId(review.bookingId, review.fromUserId))
      .set(review.toJson());

  @override
  Future<List<ReviewModel>> getReviewsFor(String userId) async {
    final snapshot = await _reviews
        .where('toUserId', isEqualTo: userId)
        .limit(50)
        .get();
    final reviews = snapshot.docs
        .map((d) => ReviewModel.fromJson(normalizeDoc(d.data())))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(reviews);
  }

  @override
  Future<ReviewModel?> getReviewForBooking(
    String bookingId,
    String fromUserId,
  ) async {
    final snapshot = await _reviews.doc(_docId(bookingId, fromUserId)).get();
    final data = snapshot.data();
    return data == null ? null : ReviewModel.fromJson(normalizeDoc(data));
  }
}

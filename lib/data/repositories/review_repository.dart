import '../models/review_model.dart';

/// Contrat d'accès aux avis laissés après une mission.
abstract class ReviewRepository {
  /// Persiste un avis. Un seul avis par réservation et par auteur :
  /// un nouvel avis sur le même booking remplace le précédent.
  Future<void> addReview(ReviewModel review);

  /// Avis reçus par un utilisateur (nounou ou parent), du plus récent
  /// au plus ancien.
  Future<List<ReviewModel>> getReviewsFor(String userId);

  /// Avis déjà laissé par [fromUserId] sur [bookingId], ou `null`.
  Future<ReviewModel?> getReviewForBooking(String bookingId, String fromUserId);
}

/// Implémentation mock : avis en mémoire de session (aucun avis initial —
/// les profils de démo affichent leur note agrégée, pas de faux avis).
class MockReviewRepository implements ReviewRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  final List<ReviewModel> _reviews = [];

  @override
  Future<void> addReview(ReviewModel review) => Future.delayed(_latency, () {
    _reviews.removeWhere(
      (r) =>
          r.bookingId == review.bookingId && r.fromUserId == review.fromUserId,
    );
    _reviews.insert(0, review);
  });

  @override
  Future<List<ReviewModel>> getReviewsFor(String userId) => Future.delayed(
    _latency,
    () => List.unmodifiable(
      _reviews.where((r) => r.toUserId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    ),
  );

  @override
  Future<ReviewModel?> getReviewForBooking(
    String bookingId,
    String fromUserId,
  ) => Future.delayed(_latency, () {
    for (final review in _reviews) {
      if (review.bookingId == bookingId && review.fromUserId == fromUserId) {
        return review;
      }
    }
    return null;
  });
}

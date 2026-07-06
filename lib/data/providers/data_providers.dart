import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/backend_config.dart';
import '../models/application_model.dart';
import '../models/booking_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/mission_model.dart';
import '../models/nanny_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';
import '../repositories/booking_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/firestore/firestore_booking_repository.dart';
import '../repositories/firestore/firestore_chat_repository.dart';
import '../repositories/firestore/firestore_mission_repository.dart';
import '../repositories/firestore/firestore_nanny_repository.dart';
import '../repositories/firestore/firestore_notification_repository.dart';
import '../repositories/firestore/firestore_profile_repository.dart';
import '../repositories/firestore/firestore_review_repository.dart';
import '../repositories/firestore/firestore_sos_repository.dart';
import '../repositories/mission_repository.dart';
import '../repositories/nanny_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/review_repository.dart';
import '../repositories/sos_repository.dart';

// ── Repositories ──────────────────────────────────────────────────────────────
// Un seul point de bascule : remplacer les implémentations Mock* par les
// implémentations Firestore (Phase 3 de l'audit) sans toucher aux écrans.

final nannyRepositoryProvider = Provider<NannyRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirestoreNannyRepository()
      : MockNannyRepository(),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirestoreBookingRepository()
      : MockBookingRepository(),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirestoreChatRepository()
      : MockChatRepository(),
);

final missionRepositoryProvider = Provider<MissionRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirestoreMissionRepository()
      : MockMissionRepository(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirestoreNotificationRepository()
      : MockNotificationRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirestoreProfileRepository()
      : MockProfileRepository(),
);

final sosRepositoryProvider = Provider<SosRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirestoreSosRepository()
      : MockSosRepository(ref.watch(notificationRepositoryProvider)),
);

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => BackendConfig.useFirebase
      ? FirestoreReviewRepository()
      : MockReviewRepository(),
);

// ── Nounous ───────────────────────────────────────────────────────────────────

final nanniesProvider = FutureProvider<List<NannyModel>>(
  (ref) => ref.watch(nannyRepositoryProvider).getNannies(),
);

final nannyByIdProvider = FutureProvider.family<NannyModel, String>(
  (ref, id) => ref.watch(nannyRepositoryProvider).getNannyById(id),
);

final favoriteNanniesProvider = FutureProvider<List<NannyModel>>(
  (ref) => ref.watch(nannyRepositoryProvider).getFavorites(),
);

final quartiersProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(nannyRepositoryProvider).getQuartiers(),
);

// ── Réservations ──────────────────────────────────────────────────────────────

final bookingsProvider = FutureProvider<List<BookingModel>>(
  (ref) => ref.watch(bookingRepositoryProvider).getBookings(),
);

final bookingByIdProvider = FutureProvider.family<BookingModel, String>(
  (ref, id) => ref.watch(bookingRepositoryProvider).getBookingById(id),
);

// ── Chat ──────────────────────────────────────────────────────────────────────

final conversationsProvider = StreamProvider<List<ConversationModel>>(
  (ref) => ref.watch(chatRepositoryProvider).watchConversations(),
);

final conversationWithProvider =
    FutureProvider.family<ConversationModel?, String>(
      (ref, otherUserId) =>
          ref.watch(chatRepositoryProvider).getConversationWith(otherUserId),
    );

final messagesProvider = StreamProvider.family<List<MessageModel>, String>(
  (ref, otherUserId) =>
      ref.watch(chatRepositoryProvider).watchMessages(otherUserId),
);

// ── Missions ──────────────────────────────────────────────────────────────────

final missionsProvider = FutureProvider<List<MissionModel>>(
  (ref) => ref.watch(missionRepositoryProvider).getMissions(),
);

final missionByIdProvider = FutureProvider.family<MissionModel, String>(
  (ref, id) => ref.watch(missionRepositoryProvider).getMissionById(id),
);

final missionApplicationsProvider =
    FutureProvider.family<List<ApplicationModel>, String>(
      (ref, missionId) => ref
          .watch(missionRepositoryProvider)
          .getApplicationsForMission(missionId),
    );

/// Candidatures déposées par la nounou connectée (plus récentes d'abord).
final myApplicationsProvider = FutureProvider<List<ApplicationModel>>(
  (ref) => ref
      .watch(missionRepositoryProvider)
      .getApplicationsForNanny(ref.watch(currentUserIdProvider)),
);

// ── Avis ──────────────────────────────────────────────────────────────────────

/// Avis reçus par un utilisateur (nounou ou parent).
final reviewsForUserProvider = FutureProvider.family<List<ReviewModel>, String>(
  (ref, userId) => ref.watch(reviewRepositoryProvider).getReviewsFor(userId),
);

// ── Notifications ─────────────────────────────────────────────────────────────

final notificationsProvider = FutureProvider<List<NotificationModel>>(
  (ref) => ref.watch(notificationRepositoryProvider).getNotifications(),
);

// ── Utilisateur courant ───────────────────────────────────────────────────────

/// Id de l'utilisateur connecté (uid Firebase, ou 'p1' en mode démo).
final currentUserIdProvider = Provider<String>(
  (ref) => ref.watch(profileRepositoryProvider).currentUserId(),
);

/// Profil saisi à l'inscription (prénom, quartier...), `null` si absent.
final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>(
  (ref) => ref.watch(profileRepositoryProvider).getCurrentUserProfile(),
);

/// Nombre de notifications non lues (badge cloche / bottom nav).
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull;
  if (notifications == null) return 0;
  return notifications.where((n) => !n.isRead).length;
});

// ── Profil / dashboard ────────────────────────────────────────────────────────

final parentStatsProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(profileRepositoryProvider).getParentStats(),
);

final nannyStatsProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(profileRepositoryProvider).getNannyStats(),
);

final upcomingMissionsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(profileRepositoryProvider).getUpcomingMissions(),
);

final recentReviewsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(profileRepositoryProvider).getRecentReviews(),
);

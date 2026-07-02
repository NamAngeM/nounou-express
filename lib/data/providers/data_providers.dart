import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/application_model.dart';
import '../models/booking_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/mission_model.dart';
import '../models/nanny_model.dart';
import '../models/notification_model.dart';
import '../repositories/booking_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/mission_repository.dart';
import '../repositories/nanny_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/profile_repository.dart';

// ── Repositories ──────────────────────────────────────────────────────────────
// Un seul point de bascule : remplacer les implémentations Mock* par les
// implémentations Firestore (Phase 3 de l'audit) sans toucher aux écrans.

final nannyRepositoryProvider = Provider<NannyRepository>(
  (ref) => MockNannyRepository(),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => MockBookingRepository(),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => MockChatRepository(),
);

final missionRepositoryProvider = Provider<MissionRepository>(
  (ref) => MockMissionRepository(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => MockNotificationRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => MockProfileRepository(),
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

final conversationsProvider = FutureProvider<List<ConversationModel>>(
  (ref) => ref.watch(chatRepositoryProvider).getConversations(),
);

final conversationWithProvider =
    FutureProvider.family<ConversationModel?, String>(
      (ref, otherUserId) =>
          ref.watch(chatRepositoryProvider).getConversationWith(otherUserId),
    );

final messagesProvider = FutureProvider.family<List<MessageModel>, String>(
  (ref, otherUserId) =>
      ref.watch(chatRepositoryProvider).getMessages(otherUserId),
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

// ── Notifications ─────────────────────────────────────────────────────────────

final notificationsProvider = FutureProvider<List<NotificationModel>>(
  (ref) => ref.watch(notificationRepositoryProvider).getNotifications(),
);

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

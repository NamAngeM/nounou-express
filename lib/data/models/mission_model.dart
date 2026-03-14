enum MissionStatus {
  pending,      // 🟡 Annonce publiée — en attente de candidatures
  confirmed,    // 🔵 Nounou sélectionnée — mission confirmée
  nannyEnRoute, // 🟣 Nounou en route
  nannyArrived, // ✅ Nounou arrivée — en attente du parent
  inProgress,   // 🟢 Garde en cours — chrono lancé
  delayed,      // ⏰ Retard signalé — prolongation en cours
  completed,    // 🏁 Parent rentré — mission terminée
  paid,         // 💰 Paiement confirmé
  reviewed,     // ⭐ Avis mutuels — mission clôturée
  cancelled,    // ❌ Annulée
}

enum LocationType { home, other, publicPlace }

enum PaymentMethod { cash, airtelMoney, moovMoney }

class DelayRequest {
  final DateTime requestedAt;
  final int minutesRequested; // 15, 30, 60, or custom
  final String reason; // 'en_route', 'bloque', 'autre'
  final bool confirmedByNanny;

  const DelayRequest({
    required this.requestedAt,
    required this.minutesRequested,
    required this.reason,
    this.confirmedByNanny = false,
  });

  double get extraCost {
    // Arrondi à la demi-heure supérieure
    if (minutesRequested <= 30) return 0.5;
    return (minutesRequested / 60).ceilToDouble();
  }
}

class MissionModel {
  final String id;
  final String parentId;
  final String parentName;
  final String parentPhotoUrl;

  // ── Lieu ────────────────────────────────────────────────────────────────────
  final String address;
  final LocationType locationType;
  final String? accessInstructions;
  final double? lat;
  final double? lng;

  // ── Mission ──────────────────────────────────────────────────────────────────
  final DateTime date;
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final bool isUrgent;

  // ── Enfants ──────────────────────────────────────────────────────────────────
  final List<String> childrenIds;       // IDs depuis le profil
  final List<String> childrenSummary;   // Ex: ["Léa, 3 ans", "Tom, 7 ans"]

  // ── Instructions ─────────────────────────────────────────────────────────────
  final String? notes;
  final List<String> needs; // Repas, Bain, Devoirs, Activités, Dodo
  final bool hasPets;
  final String? petsDescription;

  // ── Paiement ─────────────────────────────────────────────────────────────────
  final PaymentMethod paymentMethod;
  final double? maxBudgetPerHour;

  // ── Statut & Workflow ─────────────────────────────────────────────────────────
  final MissionStatus status;
  final String? selectedNannyId;
  final List<String> applicantIds;
  final DateTime publishedAt;

  // ── Runtime (jour J) ─────────────────────────────────────────────────────────
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final List<DelayRequest> delayRequests;
  final double? hourlyRateSnapshot; // Tarif figé au moment de la confirmation

  const MissionModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.parentPhotoUrl,
    required this.address,
    required this.locationType,
    this.accessInstructions,
    this.lat,
    this.lng,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isUrgent,
    required this.childrenIds,
    required this.childrenSummary,
    this.notes,
    required this.needs,
    required this.hasPets,
    this.petsDescription,
    required this.paymentMethod,
    this.maxBudgetPerHour,
    required this.status,
    this.selectedNannyId,
    required this.applicantIds,
    required this.publishedAt,
    this.actualStartTime,
    this.actualEndTime,
    this.delayRequests = const [],
    this.hourlyRateSnapshot,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Duration get plannedDuration {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return end.difference(start);
  }

  double get plannedHours => plannedDuration.inMinutes / 60.0;

  double estimatedCost(double hourlyRate) =>
      (plannedHours * hourlyRate).ceilToDouble() * hourlyRate ~/ hourlyRate * hourlyRate;

  Duration? get actualDuration {
    if (actualStartTime == null || actualEndTime == null) return null;
    return actualEndTime!.difference(actualStartTime!);
  }

  double finalCost(double hourlyRate) {
    if (actualDuration == null) return plannedHours * hourlyRate;
    final hours = actualDuration!.inMinutes / 60.0;
    return hours.ceil() * hourlyRate;
  }

  bool get hasDelay => delayRequests.isNotEmpty;

  MissionModel copyWith({MissionStatus? status, String? selectedNannyId,
      DateTime? actualStartTime, DateTime? actualEndTime,
      List<DelayRequest>? delayRequests, List<String>? applicantIds}) {
    return MissionModel(
      id: id, parentId: parentId, parentName: parentName,
      parentPhotoUrl: parentPhotoUrl, address: address,
      locationType: locationType, accessInstructions: accessInstructions,
      lat: lat, lng: lng, date: date, startTime: startTime, endTime: endTime,
      isUrgent: isUrgent, childrenIds: childrenIds,
      childrenSummary: childrenSummary, notes: notes, needs: needs,
      hasPets: hasPets, petsDescription: petsDescription,
      paymentMethod: paymentMethod, maxBudgetPerHour: maxBudgetPerHour,
      status: status ?? this.status,
      selectedNannyId: selectedNannyId ?? this.selectedNannyId,
      applicantIds: applicantIds ?? this.applicantIds,
      publishedAt: publishedAt,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      delayRequests: delayRequests ?? this.delayRequests,
      hourlyRateSnapshot: hourlyRateSnapshot,
    );
  }

  static DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }
}

// ── Mock data ─────────────────────────────────────────────────────────────────
final List<MissionModel> mockMissions = [
  MissionModel(
    id: 'm1', parentId: 'p1', parentName: 'Mme Ondo',
    parentPhotoUrl: '', address: 'Résidence Angondjé, Bât B Apt 12',
    locationType: LocationType.home, date: DateTime.now().add(const Duration(hours: 3)),
    startTime: '18:00', endTime: '22:00', isUrgent: false,
    childrenIds: ['c1'], childrenSummary: ['Léa, 3 ans'],
    needs: ['Repas', 'Bain', 'Dodo'], hasPets: false,
    paymentMethod: PaymentMethod.airtelMoney, maxBudgetPerHour: 3000,
    status: MissionStatus.pending, applicantIds: [],
    publishedAt: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  MissionModel(
    id: 'm2', parentId: 'p2', parentName: 'M. Moussavou',
    parentPhotoUrl: '', address: 'Quartier Glass, Rue de la Paix',
    locationType: LocationType.home, date: DateTime.now().add(const Duration(hours: 1)),
    startTime: '14:00', endTime: '17:00', isUrgent: true,
    childrenIds: ['c2', 'c3'], childrenSummary: ['Tom, 5 ans', 'Nina, 2 ans'],
    needs: ['Repas', 'Activités'], hasPets: true, petsDescription: 'Un chien',
    paymentMethod: PaymentMethod.cash, maxBudgetPerHour: 4000,
    status: MissionStatus.pending, applicantIds: [],
    publishedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  MissionModel(
    id: 'm3', parentId: 'p3', parentName: 'Mme Nzigou',
    parentPhotoUrl: '', address: 'Libreville Centre, Av. Bouët',
    locationType: LocationType.home, date: DateTime.now(),
    startTime: '08:00', endTime: '17:00', isUrgent: false,
    childrenIds: ['c4'], childrenSummary: ['Max, 8 ans'],
    needs: ['Devoirs', 'Repas'], hasPets: false,
    paymentMethod: PaymentMethod.moovMoney, maxBudgetPerHour: 2500,
    status: MissionStatus.inProgress, selectedNannyId: 'n1',
    applicantIds: ['n1', 'n2'],
    publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
    actualStartTime: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];

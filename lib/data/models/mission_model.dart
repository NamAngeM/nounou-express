enum MissionStatus {
  pending, // 🟡 Annonce publiée — en attente de candidatures
  confirmed, // 🔵 Nounou sélectionnée — mission confirmée
  nannyEnRoute, // 🟣 Nounou en route
  nannyArrived, // ✅ Nounou arrivée — en attente du parent
  inProgress, // 🟢 Garde en cours — chrono lancé
  delayed, // ⏰ Retard signalé — prolongation en cours
  completed, // 🏁 Parent rentré — mission terminée
  paid, // 💰 Paiement confirmé
  reviewed, // ⭐ Avis mutuels — mission clôturée
  cancelled, // ❌ Annulée
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

  Map<String, dynamic> toJson() => {
    'requestedAt': requestedAt.toIso8601String(),
    'minutesRequested': minutesRequested,
    'reason': reason,
    'confirmedByNanny': confirmedByNanny,
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory DelayRequest.fromJson(Map<String, dynamic> json) => DelayRequest(
    requestedAt:
        DateTime.tryParse(json['requestedAt'] as String? ?? '') ??
        DateTime.now(),
    minutesRequested: (json['minutesRequested'] as num?)?.toInt() ?? 0,
    reason: json['reason'] as String? ?? '',
    confirmedByNanny: json['confirmedByNanny'] as bool? ?? false,
  );
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
  final String endTime; // "HH:mm"
  final bool isUrgent;

  // ── Enfants ──────────────────────────────────────────────────────────────────
  final List<String> childrenIds; // IDs depuis le profil
  final List<String> childrenSummary; // Ex: ["Léa, 3 ans", "Tom, 7 ans"]

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
      (plannedHours * hourlyRate).ceilToDouble();

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

  MissionModel copyWith({
    MissionStatus? status,
    String? selectedNannyId,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    List<DelayRequest>? delayRequests,
    List<String>? applicantIds,
  }) {
    return MissionModel(
      id: id,
      parentId: parentId,
      parentName: parentName,
      parentPhotoUrl: parentPhotoUrl,
      address: address,
      locationType: locationType,
      accessInstructions: accessInstructions,
      lat: lat,
      lng: lng,
      date: date,
      startTime: startTime,
      endTime: endTime,
      isUrgent: isUrgent,
      childrenIds: childrenIds,
      childrenSummary: childrenSummary,
      notes: notes,
      needs: needs,
      hasPets: hasPets,
      petsDescription: petsDescription,
      paymentMethod: paymentMethod,
      maxBudgetPerHour: maxBudgetPerHour,
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
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'parentId': parentId,
    'parentName': parentName,
    'parentPhotoUrl': parentPhotoUrl,
    'address': address,
    'locationType': locationType.name,
    'accessInstructions': accessInstructions,
    'lat': lat,
    'lng': lng,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'isUrgent': isUrgent,
    'childrenIds': childrenIds,
    'childrenSummary': childrenSummary,
    'notes': notes,
    'needs': needs,
    'hasPets': hasPets,
    'petsDescription': petsDescription,
    'paymentMethod': paymentMethod.name,
    'maxBudgetPerHour': maxBudgetPerHour,
    'status': status.name,
    'selectedNannyId': selectedNannyId,
    'applicantIds': applicantIds,
    'publishedAt': publishedAt.toIso8601String(),
    'actualStartTime': actualStartTime?.toIso8601String(),
    'actualEndTime': actualEndTime?.toIso8601String(),
    'delayRequests': delayRequests.map((e) => e.toJson()).toList(),
    'hourlyRateSnapshot': hourlyRateSnapshot,
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory MissionModel.fromJson(Map<String, dynamic> json) {
    final locationTypeName = json['locationType'] as String? ?? '';
    final paymentMethodName = json['paymentMethod'] as String? ?? '';
    final statusName = json['status'] as String? ?? '';
    return MissionModel(
      id: json['id'] as String? ?? '',
      parentId: json['parentId'] as String? ?? '',
      parentName: json['parentName'] as String? ?? '',
      parentPhotoUrl: json['parentPhotoUrl'] as String? ?? '',
      address: json['address'] as String? ?? '',
      locationType: LocationType.values.firstWhere(
        (v) => v.name == locationTypeName,
        orElse: () => LocationType.home,
      ),
      accessInstructions: json['accessInstructions'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isUrgent: json['isUrgent'] as bool? ?? false,
      childrenIds: (json['childrenIds'] as List?)?.cast<String>() ?? const [],
      childrenSummary:
          (json['childrenSummary'] as List?)?.cast<String>() ?? const [],
      notes: json['notes'] as String?,
      needs: (json['needs'] as List?)?.cast<String>() ?? const [],
      hasPets: json['hasPets'] as bool? ?? false,
      petsDescription: json['petsDescription'] as String?,
      paymentMethod: PaymentMethod.values.firstWhere(
        (v) => v.name == paymentMethodName,
        orElse: () => PaymentMethod.cash,
      ),
      maxBudgetPerHour: (json['maxBudgetPerHour'] as num?)?.toDouble(),
      status: MissionStatus.values.firstWhere(
        (v) => v.name == statusName,
        orElse: () => MissionStatus.pending,
      ),
      selectedNannyId: json['selectedNannyId'] as String?,
      applicantIds: (json['applicantIds'] as List?)?.cast<String>() ?? const [],
      publishedAt:
          DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
      actualStartTime: json['actualStartTime'] == null
          ? null
          : DateTime.tryParse(json['actualStartTime'] as String? ?? ''),
      actualEndTime: json['actualEndTime'] == null
          ? null
          : DateTime.tryParse(json['actualEndTime'] as String? ?? ''),
      delayRequests:
          (json['delayRequests'] as List?)
              ?.map((e) => DelayRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hourlyRateSnapshot: (json['hourlyRateSnapshot'] as num?)?.toDouble(),
    );
  }
}

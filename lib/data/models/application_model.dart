enum ApplicationStatus { pending, accepted, rejected }

class ApplicationModel {
  final String id;
  final String missionId;
  final String nannyId;
  final String nannyName;
  final String nannyPhotoUrl;
  final double nannyRating;
  final int nannyReviewCount;
  final double hourlyRate;
  final int experienceYears;
  final List<String> skills;
  final String? message; // Message de candidature
  final DateTime appliedAt;
  final ApplicationStatus status;

  const ApplicationModel({
    required this.id,
    required this.missionId,
    required this.nannyId,
    required this.nannyName,
    required this.nannyPhotoUrl,
    required this.nannyRating,
    required this.nannyReviewCount,
    required this.hourlyRate,
    required this.experienceYears,
    required this.skills,
    this.message,
    required this.appliedAt,
    this.status = ApplicationStatus.pending,
  });

  ApplicationModel copyWith({ApplicationStatus? status}) => ApplicationModel(
    id: id,
    missionId: missionId,
    nannyId: nannyId,
    nannyName: nannyName,
    nannyPhotoUrl: nannyPhotoUrl,
    nannyRating: nannyRating,
    nannyReviewCount: nannyReviewCount,
    hourlyRate: hourlyRate,
    experienceYears: experienceYears,
    skills: skills,
    message: message,
    appliedAt: appliedAt,
    status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'missionId': missionId,
    'nannyId': nannyId,
    'nannyName': nannyName,
    'nannyPhotoUrl': nannyPhotoUrl,
    'nannyRating': nannyRating,
    'nannyReviewCount': nannyReviewCount,
    'hourlyRate': hourlyRate,
    'experienceYears': experienceYears,
    'skills': skills,
    'message': message,
    'appliedAt': appliedAt.toIso8601String(),
    'status': status.name,
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ?? '';
    return ApplicationModel(
      id: json['id'] as String? ?? '',
      missionId: json['missionId'] as String? ?? '',
      nannyId: json['nannyId'] as String? ?? '',
      nannyName: json['nannyName'] as String? ?? '',
      nannyPhotoUrl: json['nannyPhotoUrl'] as String? ?? '',
      nannyRating: (json['nannyRating'] as num?)?.toDouble() ?? 0,
      nannyReviewCount: (json['nannyReviewCount'] as num?)?.toInt() ?? 0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      skills: (json['skills'] as List?)?.cast<String>() ?? const [],
      message: json['message'] as String?,
      appliedAt:
          DateTime.tryParse(json['appliedAt'] as String? ?? '') ??
          DateTime.now(),
      status: ApplicationStatus.values.firstWhere(
        (v) => v.name == statusName,
        orElse: () => ApplicationStatus.pending,
      ),
    );
  }
}


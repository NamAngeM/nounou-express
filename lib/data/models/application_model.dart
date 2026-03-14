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
}

// ── Mock data ─────────────────────────────────────────────────────────────────
final List<ApplicationModel> mockApplications = [
  ApplicationModel(
    id: 'a1',
    missionId: 'm1',
    nannyId: 'n1',
    nannyName: 'Ange Mba',
    nannyPhotoUrl: '',
    nannyRating: 4.8,
    nannyReviewCount: 23,
    hourlyRate: 2500,
    experienceYears: 3,
    skills: ['Premiers secours', 'Cuisine', 'Aide aux devoirs'],
    message: 'Disponible et expérimentée avec les enfants de 0 à 6 ans.',
    appliedAt: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  ApplicationModel(
    id: 'a2',
    missionId: 'm1',
    nannyId: 'n2',
    nannyName: 'Marie-Claire Nzamba',
    nannyPhotoUrl: '',
    nannyRating: 4.5,
    nannyReviewCount: 11,
    hourlyRate: 2000,
    experienceYears: 2,
    skills: ['Cuisine', 'Dodo nourrissons', 'Activités créatives'],
    message: null,
    appliedAt: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  ApplicationModel(
    id: 'a3',
    missionId: 'm1',
    nannyId: 'n3',
    nannyName: 'Sylvie Obiang',
    nannyPhotoUrl: '',
    nannyRating: 4.9,
    nannyReviewCount: 47,
    hourlyRate: 3000,
    experienceYears: 6,
    skills: [
      'Premiers secours',
      'Aide aux devoirs',
      'Langues étrangères',
      'Cuisine',
    ],
    message: 'CAP Petite Enfance, 6 ans d\'expérience. Référence disponible.',
    appliedAt: DateTime.now().subtract(const Duration(minutes: 22)),
  ),
];

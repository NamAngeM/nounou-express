import 'user_model.dart';

class NannyModel extends UserModel {
  final int experience;
  final double hourlyRate;
  final double rating;
  final int totalMissions;
  final List<String> badges;
  final List<String> skills;
  final bool isVerified;
  final String bio;
  final String quartier;

  /// Disponibilités déclarées à l'inscription :
  /// jour ('Lundi'...'Dimanche') → créneaux ('Matin', 'Après-midi',
  /// 'Soir', 'Nuit'). Vide si non renseignées.
  final Map<String, List<String>> availability;

  NannyModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.avatar,
    required super.createdAt,
    required this.experience,
    required this.hourlyRate,
    required this.rating,
    required this.totalMissions,
    required this.badges,
    required this.skills,
    required this.isVerified,
    required this.bio,
    this.quartier = '',
    this.availability = const {},
  });

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'experience': experience,
    'hourlyRate': hourlyRate,
    'rating': rating,
    'totalMissions': totalMissions,
    'badges': badges,
    'skills': skills,
    'isVerified': isVerified,
    'bio': bio,
    'quartier': quartier,
    'availability': availability,
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory NannyModel.fromJson(Map<String, dynamic> json) => NannyModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    role: json['role'] as String? ?? '',
    avatar: json['avatar'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    experience: (json['experience'] as num?)?.toInt() ?? 0,
    hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    totalMissions: (json['totalMissions'] as num?)?.toInt() ?? 0,
    badges: (json['badges'] as List?)?.cast<String>() ?? const [],
    skills: (json['skills'] as List?)?.cast<String>() ?? const [],
    isVerified: json['isVerified'] as bool? ?? false,
    bio: json['bio'] as String? ?? '',
    quartier: json['quartier'] as String? ?? '',
    availability:
        (json['availability'] as Map?)?.map(
          (day, slots) =>
              MapEntry(day.toString(), (slots as List).cast<String>()),
        ) ??
        const {},
  );
}

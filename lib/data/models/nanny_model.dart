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
  });
}

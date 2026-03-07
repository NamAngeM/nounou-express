class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final DateTime createdAt;

  UserModel({required this.id, required this.name, required this.email, required this.phone, required this.role, this.avatar, required this.createdAt});
}

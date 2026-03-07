class NotificationModel {
  final String id, userId, title, body, type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({required this.id, required this.userId, required this.title, required this.body, required this.type, required this.isRead, required this.createdAt});
}

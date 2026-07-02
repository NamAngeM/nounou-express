class MessageModel {
  final String id, senderId, receiverId, content;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });
}

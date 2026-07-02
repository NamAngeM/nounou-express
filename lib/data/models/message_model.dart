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

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'receiverId': receiverId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'] as String? ?? '',
    senderId: json['senderId'] as String? ?? '',
    receiverId: json['receiverId'] as String? ?? '',
    content: json['content'] as String? ?? '',
    timestamp:
        DateTime.tryParse(json['timestamp'] as String? ?? '') ??
        DateTime.now(),
    isRead: json['isRead'] as bool? ?? false,
  );
}

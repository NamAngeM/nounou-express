class ConversationModel {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isLastMessageRead;
  final bool isOnline;
  final DateTime? lastSeen;

  ConversationModel({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isLastMessageRead,
    this.isOnline = false,
    this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'otherUserId': otherUserId,
    'otherUserName': otherUserName,
    'otherUserAvatar': otherUserAvatar,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.toIso8601String(),
    'unreadCount': unreadCount,
    'isLastMessageRead': isLastMessageRead,
    'isOnline': isOnline,
    'lastSeen': lastSeen?.toIso8601String(),
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id'] as String? ?? '',
        otherUserId: json['otherUserId'] as String? ?? '',
        otherUserName: json['otherUserName'] as String? ?? '',
        otherUserAvatar: json['otherUserAvatar'] as String?,
        lastMessage: json['lastMessage'] as String? ?? '',
        lastMessageTime:
            DateTime.tryParse(json['lastMessageTime'] as String? ?? '') ??
            DateTime.now(),
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        isLastMessageRead: json['isLastMessageRead'] as bool? ?? false,
        isOnline: json['isOnline'] as bool? ?? false,
        lastSeen: json['lastSeen'] == null
            ? null
            : DateTime.tryParse(json['lastSeen'] as String? ?? ''),
      );
}

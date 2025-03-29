// lib/views/models/chat_message.dart
class ChatMessage {
  final String id;
  final String groupId;
  final String message;
  final String sender;
  final bool isAnonymous;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.message,
    required this.sender,
    required this.isAnonymous,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUsername) {
    return ChatMessage(
      id: json['_id'] ?? '',
      groupId: json['groupId'] ?? '',
      message: json['message'] ?? '',
      sender: json['sender'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isMe: json['sender'] == currentUsername,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'message': message,
      'sender': sender,
      'isAnonymous': isAnonymous,
    };
  }

  // This displays 'Anonymous' for anonymous messages while preserving sender name for the current user
  String get displayName {
    if (isMe) {
      return isAnonymous ? 'You (Anonymous)' : sender;
    } else {
      return isAnonymous ? 'Anonymous' : sender;
    }
  }

  // Create a copy of this message with modified properties
  ChatMessage copyWith({
    String? id,
    String? groupId,
    String? message,
    String? sender,
    bool? isAnonymous,
    DateTime? timestamp,
    bool? isMe,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
    );
  }
}
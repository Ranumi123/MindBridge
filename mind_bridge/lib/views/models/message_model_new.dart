class MessageModel {
  final String id;
  final String message;
  final String sender;
  final DateTime timestamp;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    this.isMe = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      message: json['message'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['sender'] == 'You', // Assuming 'You' is the current user
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
    };
  }

  // Format the timestamp for display
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
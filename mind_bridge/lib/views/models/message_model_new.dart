class MessageModel {
  final String id;
  final String message;
  final DateTime timestamp;

  MessageModel({required this.id, required this.message, required this.timestamp});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

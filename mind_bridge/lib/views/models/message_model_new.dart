class MessageModel {
  final String id;
  final String message;
  final String sender;
  final DateTime timestamp;

  MessageModel({required this.id, required this.message, required this.sender, required this.timestamp});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      message: json['message'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

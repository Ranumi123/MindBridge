class Message {
  final String role; // 'user' or 'bot'
  final String content; // The message text
  final DateTime timestamp; // Timestamp of the message

  Message({
    required this.role,
    required this.content,
    required this.timestamp, // Add timestamp parameter
  });
}
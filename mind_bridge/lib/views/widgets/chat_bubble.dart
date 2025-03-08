import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp; // Add timestamp parameter

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp, // Make timestamp required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, // Align timestamp to the end
          children: [
            Text(
              message,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4), // Add spacing between message and timestamp
            Text(
              _formatTimestamp(timestamp), // Format the timestamp
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10, // Smaller font size for timestamp
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format the timestamp
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
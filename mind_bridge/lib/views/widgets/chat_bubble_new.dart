import 'package:flutter/material.dart';

/// A widget representing an individual chat message bubble.
class ChatBubble extends StatelessWidget {
  // Message data containing the text, sender status (isMe), and time.
  final Map<String, dynamic> message;

  // Constructor with a required 'message' parameter.
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Determine if the message is sent by the current user (true) or received (false).
    final isMe = message['isMe'] as bool;

    return Align(
      // Align messages to the right if sent by the user, otherwise to the left.
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // Add vertical spacing between message bubbles.
        margin: const EdgeInsets.symmetric(vertical: 5),
        // Padding for content inside the bubble.
        padding: const EdgeInsets.all(12),
        // Styling the chat bubble.
        decoration: BoxDecoration(
          // Different colors for sent and received messages.
          color: isMe ? Colors.blue[100] : const Color.fromARGB(255, 195, 176, 176),
          // Rounded corners for the bubble.
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          // Align text to the right for sent messages, left for received.
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Display the chat message text.
            Text(
              message['text']!,
              style: const TextStyle(fontSize: 16),
            ),
            // Display the timestamp in smaller, grey text.
            Text(
              message['time']!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

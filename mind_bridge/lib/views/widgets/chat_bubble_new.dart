import 'package:flutter/material.dart';
import '../models/message_model_new.dart';

/// A widget representing an individual chat message bubble in WhatsApp style.
class ChatBubble extends StatelessWidget {
  // Message data
  final MessageModel message;

  // Constructor with a required 'message' parameter.
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Get screen width for setting max width of bubble
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Align(
      // Align messages to the right if sent by the user, otherwise to the left.
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.75, // Limit bubble width to 75% of screen
        ),
        child: Container(
          // Add margin for spacing between bubbles
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          // Padding for content inside the bubble
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          // WhatsApp-style decoration
          decoration: BoxDecoration(
            color: message.isMe 
                ? const Color(0xFFDCF8C6) // Light green for sent messages
                : Colors.white, // White for received messages
            borderRadius: BorderRadius.circular(8),
            // Add subtle shadow for depth
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show sender name for messages from others
              if (!message.isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              
              // Message content
              Text(
                message.message,
                style: const TextStyle(fontSize: 16),
              ),
              
              // Timestamp and delivery status
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (message.isMe) ...[
                          const SizedBox(width: 3),
                          // Double check mark for delivered messages
                          Icon(
                            Icons.done_all,
                            size: 14,
                            color: Colors.blue.shade600, // Blue for read
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
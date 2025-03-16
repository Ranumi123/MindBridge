import 'package:flutter/material.dart';

// Define ChatBubble widget directly in this file to avoid import errors
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
              message['text'],
              style: const TextStyle(fontSize: 16),
            ),
            // Display the timestamp in smaller, grey text.
            Text(
              message['time'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hey! How are you doing?', 'isMe': false, 'time': '10:47 PM'},
    {'text': 'I\'m good, thanks! How about you?', 'isMe': true, 'time': '10:48 PM'},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _controller.text,
        'isMe': true,
        'time': '10:49 PM',
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group 1 - Floyd'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // Light pattern background for WhatsApp-like appearance
                color: Colors.grey.shade200,
                image: const DecorationImage(
                  image: NetworkImage('https://i.pinimg.com/originals/97/c0/07/97c00759d90d786d9b6096d274ad3e07.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.2,
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    ChatBubble(message: _messages[index]),
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Colors.white,
      child: Row(
        children: [
          // Attachment button
          IconButton(
            icon: const Icon(Icons.attach_file),
            color: Colors.grey.shade600,
            onPressed: () {},
          ),
          
          // Text input field
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          
          // Send button
          IconButton(
            icon: const Icon(Icons.send, color: Colors.teal),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
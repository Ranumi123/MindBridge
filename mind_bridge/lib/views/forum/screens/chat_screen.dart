import 'package:flutter/material.dart';
import '../repositories/chat_repository.dart';
import '../../models/message_model_new.dart';

class ChatScreen extends StatefulWidget {
  final String groupName;

  const ChatScreen({super.key, required this.groupName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final TextEditingController _messageController = TextEditingController();
  List<MessageModel> messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final fetchedMessages = await _chatRepository.getMessages(widget.groupName);
    setState(() => messages = fetchedMessages);
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatRepository.sendMessage(widget.groupName, _messageController.text);
      fetchMessages(); // Refresh messages
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index].message),
                  subtitle: Text(messages[index].timestamp.toLocal().toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

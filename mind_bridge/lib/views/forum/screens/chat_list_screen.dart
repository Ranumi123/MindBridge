import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {'name': 'Floyd Miles', 'message': 'New message', 'time': '10:47 PM'},
      {'name': 'Devon Lane', 'message': 'Check this out!', 'time': '10:45 PM'},
      {'name': 'Jerome Bell', 'message': 'What do you think?', 'time': '9:30 PM'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Community Forum')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            title: Text(chat['name']!),
            subtitle: Text(chat['message']!),
            trailing: Text(chat['time']!),
            onTap: () => Navigator.pushNamed(context, '/chatforum'),
          );
        },
      ),
    );
  }
}
